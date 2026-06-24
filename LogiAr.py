import hashlib
import secrets
from datetime import datetime, timedelta
from abc import ABC, abstractmethod


class Configuracion:
    #constructor, genera un token aleatorio, para luego generar el hash ya que no 
    #se guardan las contraseñas sino los hash generados con dichas contraseñas
    def __init__(self, clave_inicial: str):
        self._salt = secrets.token_hex(16)
        self._hash_clave = self.generar_hash(clave_inicial)

    #metodo que genera el hash con el token y la clave
    def generar_hash(self, clave: str) -> str:
        entrada = self._salt + clave
        return hashlib.sha256(entrada.encode()).hexdigest()

    #metodo que verifica si el hash generado con la contraseña coincide con el hash
    #generado originalmente
    def validar_clave(self, clave: str) -> bool:
        return self.generar_hash(clave) == self._hash_clave


class Paquete:
    #constructor
    def __init__(self, peso: float):
        self._peso = peso

    #retorna el peso que es privado
    def get_peso(self) -> float:
        return self._peso

    #genera un string de identificador y peso
    def obtener_detalle(self, indice: int) -> str:
        return f"  * Paquete {indice} ({self._peso} kg)"


class Contenedor:
    #constructor
    def __init__(self, nombre: str):
        self._nombre = nombre
        self._paquetes = []

    #agregar paquetes de forma segura
    def agregar_paquete(self, paquete: Paquete) -> None:
        self._paquetes.append(paquete)

    #pide el peso a cada paquete (el no calcula, solo suma... Tell, Don't Ask)
    def get_peso_total(self) -> float:
        return sum(p.get_peso() for p in self._paquetes)

    #genera reporte de texto detallado del contenedor y sus paquetes
    def obtener_detalle(self) -> str:
        lineas = [f" {self._nombre} (Peso: {self.get_peso_total()} kg), contiene:"]
        lineas.extend(p.obtener_detalle(i) for i, p in enumerate(self._paquetes, 1))
        return "\n".join(lineas)

#clase abstracta, es el contrato base (o clase padre) de los transportes
class Transporte(ABC):
    #constructor
    def __init__(self, nro_id: int, patente: str):
        self._nro_id = nro_id
        self._patente = patente

    #returna id ya que es atributo priv
    def get_id(self) -> int:
        return self._nro_id

    #metodo abstracto que todas las clases heredadas tengan que definir este metodo
    @abstractmethod
    def obtener_descripcion(self) -> str:
        pass


class Avion(Transporte):
    #constructor, usa constructor clase abs y agrega atributos
    def __init__(self, nro_id: int, patente: str, tiempo_vuelo: float):
        super().__init__(nro_id, patente)
        self._tiempo_vuelo = tiempo_vuelo

    #definicion de metodo abstracto
    def obtener_descripcion(self) -> str:
        return f"Avion {self._patente}"


class Camion(Transporte):
    #constructor, usa constructor clase abs y agrega atributos
    def __init__(self, nro_id: int, patente: str, capacidad_kg: float):
        super().__init__(nro_id, patente)
        self._capacidad_kg = capacidad_kg

    #definicion de metodo abstracto
    def obtener_descripcion(self) -> str:
        return f"Camion {self._patente}"


class Despacho:
    #constructor
    def __init__(self):
        self._fecha_despacho = datetime.now()
        self._estado = "PENDIENTE"
        self._contenedores = []
        self._transporte = None

    #agerga contenedor al despacho
    def agregar_contenedor(self, contenedor: Contenedor) -> None:
        self._contenedores.append(contenedor)

    #agerga un unico transporte
    def asignar_transporte(self, transporte: Transporte) -> None:
        self._transporte = transporte
        self._estado = "DESPACHADO"

    #pide el peso a cada contenedor y cada contenedor le pide
    #a cada paquete (el no calcula, solo suma... Tell, Don't Ask)
    def get_peso_total(self) -> float:
        return sum(c.get_peso_total() for c in self._contenedores)

    #retorna el estado del despacho "pendiente" o "despachado"
    def get_estado(self) -> str:
        return self._estado

    #verifica si la fecha de despacho esta entre las fechas solicitadas
    def esta_en_periodo(self, fecha_inicio: datetime, fecha_fin: datetime) -> bool:
        return fecha_inicio <= self._fecha_despacho <= fecha_fin

    #pide a cada contenedor que de su detalle, y a la vez los contenedores les pide
    #a los paquetes que den su detalle
    def obtener_detalle_carga(self) -> str:
        return "\n".join(c.obtener_detalle() for c in self._contenedores)

#clase controladora
class SistemaLogistica:
    #constructor que inicia la configuracion y se prepara para almacenar lista de desapchos
    def __init__(self, clave_sistema: str):
        self._sistema_seguridad = Configuracion(clave_sistema)
        self._despachos = []

    #metodo que se encarga de despachar; valida la clave, carga la lista de contenedores
    #asigna el transporte, y esta correcto despacha
    def despachar(self, clave: str, carga: list[Contenedor], transporte: Transporte) -> None:
        if self._sistema_seguridad.validar_clave(clave):
            nuevo_despacho = Despacho()
            for contenedor in carga:
                nuevo_despacho.agregar_contenedor(contenedor)

            nuevo_despacho.asignar_transporte(transporte)
            self._despachos.append(nuevo_despacho)

            print("\n[PEDIDO DESPACHADO]")
            print(f"Identidad del Transporte (ID: {transporte.get_id()}): {transporte.obtener_descripcion()}")
            print(f"Estado: {nuevo_despacho.get_estado()} exitosamente.")
            print(f"Carga Total: {nuevo_despacho.get_peso_total()} kg.")
            print("Verificación de Seguridad: Hash SHA256 Validado.")
            print("--------------------------------------------------")
            print("Detalle de la Carga:")
            print(nuevo_despacho.obtener_detalle_carga())
        else:
            print("Error: Clave de seguridad incorrecta.")

    #calcula los el peso movido en cierto tiempo determinado, filtrado por fecha de despacho
    #y sumando los pesos si se encuentran dentro del rango
    def calcular_sumatoria_pesos(self, fecha_inicio: datetime, fecha_fin: datetime) -> float:
        total = sum(d.get_peso_total() for d in self._despachos if d.esta_en_periodo(fecha_inicio, fecha_fin))
        print(f"\nSumatoria total de peso transportado en el periodo: {total} kg.")
        return total


# --- PRUEBA DE EJECUCIÓN ---

# 1. Se crea el sistema y un avión
logi_ar = SistemaLogistica("logistica123")
avion = Avion(1402345678, "LV-X500", 10.5)

# 2. Se crea la carga
cont_a = Contenedor("Contenedor A")
cont_a.agregar_paquete(Paquete(50))
cont_a.agregar_paquete(Paquete(50))

cont_b = Contenedor("Contenedor B")
cont_b.agregar_paquete(Paquete(120))

carga_completa = [cont_a, cont_b]

# 3. Intento con clave incorrecta
logi_ar.despachar("clave_incorrecta", carga_completa, avion)

# 4. Despacho con clave correcta
logi_ar.despachar("logistica123", carga_completa, avion)

# 5. Prueba de método calcular_sumatoria_pesos
fecha_desde = datetime.now() - timedelta(days=1)
fecha_hasta = datetime.now() + timedelta(days=1)
logi_ar.calcular_sumatoria_pesos(fecha_desde, fecha_hasta)
