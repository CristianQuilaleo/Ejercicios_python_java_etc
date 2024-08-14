
recaudado = 0
platinum = 0
gold = 0
silver = 0
import numpy as np
i = 1
arreglo = np.zeros((10,10))
for f in range(10):
    for c in range(10):
        arreglo[f][c] = i
        i+=1

lista = []
totaltotal = 0

print("Bienvenido al sistema de creativos.cl")
print("*-------------------------------------*")
print("Para compra de entradas, digite 1")
print("Para mostrar ubicaciones disponibles, digite 2")
print("Para ver listado de asistentes, digite 3")
print("Para ver las ganancias, digite 4.")
print("Para salir, digite 5")

eleccion = int(input("Que operacion desea realizar? Digite el numero"))


if eleccion == 1:
        revisar = 0
        compra = int(input("¿Cuantas entradas desea comprar?"))
        while revisar < compra:
            print(arreglo)
            asiento = int(input("Elija su asiento, por favor"))
            for f in range(10):
                for c in range(10):
                    if arreglo[f][c] == asiento:
                        print("Este asiento se encuentra disponible")
                        rut = int(input("Para continuar, ingrese su rut, sin puntos, guion ni digito verificador"))
                        lista.append(rut)
                        if arreglo[f][c] <= 20:
                            print("El monto a pagar por cada entrada planitum es de 120.000")
                            totaltotal = totaltotal + 120000
                            platinum += 1
                        elif arreglo[f][c] > 20 and arreglo[f][c] <= 50:
                            print("el monto a pagar por cada entrada gold es de 80.000")
                            totaltotal = totaltotal + 80000
                            gold += 1
                        elif arreglo[f][c] > 50:
                            print("El monto a pagar por cada entrada silver es de 50.000")
                            totaltotal = totaltotal + 50000
                            silver += 1
                        arreglo[f][c] = 0
                        no_existe = 1
                        revisar += 1
                        print(f"Transaccion completada, el total de su compra es de {totaltotal}")
            if no_existe == 0:
                print('Asiento no disponible, por favor elija otro')



if eleccion == 2:
    print("usted ha elegido ver las ubicaciones disponibles")
    print(arreglo)

if eleccion == 3:
    print("Usted ha elegido ver el listado de asistentes, acá encontrara sus ruts ordenados de menor a mayor")
    lista.sort()
    print(lista)

if eleccion == 4:
    def recaudado():
        return(f"El total recaudado por concepto de venta de entradas es de {totaltotal}")

    print(recaudado())

if eleccion == 5:
    print("Has elegido salir, gracias por usar el sistema de creativos.cl")