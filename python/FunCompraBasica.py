
def list():
    lista=[ i for i in range(1,101)]
    
def compra():
    opci=int(input("Selecciona una opcion segun su numero.\n1.Platinum $120.000(Asiento 1 al 20)\n2.Gold $80.000 (Asiento 21 al 50)\n3.Silver $50.000(Asiento 51 al 100)\n:"))
    list()
    if opci==1 or opci==2 or opci==3:
        if opci ==1:
            platinum()
        if opci ==2:
            gold()
        if opci ==3:
            silver()            
    else:
        print("La opcion ingresada no existe, intentelo de nuevo")
        compra()
       

    
"""import numpy as np 
matriz=np.array(lista)
print (matriz)"""

        
def platinum():
    asplat=int(input("¿Que asiento necesita?\n:"))
    if asplat ==14 or asplat==15 or asplat==16:
        print("Los asientos ya estan ocupados, intente de nuevo")
        platinum()   
    else:
        print("La compra ya esta hecha\nSon 120.000")
        cont=int(input("¿Desea continuar comprando? 1=SI 2=NO\n:"))
        if cont==1:
            compra()
        else:
            print("Hasta luego") 
        
def gold():
    asgold=int(input("¿que asientos necesita?\n:"))
    if asgold ==33 or asgold==45:
        print("Los asientos ya estan ocupados, intente de nuevo")    
    else:
        print("La compra ya esta hecha\n Son $80.000")   
        cont=int(input("¿Desea continuar comprando? 1=SI 2=NO\n:"))
        if cont==1:
            gold()
        else:
            print("Hasta luego")
        
def silver():
    assilver=int(input("¿Que asiento necesita?\n:"))
    if assilver >=51 and assilver <=100:
        print("Cuesta $50.000")
        cont=int(input("¿Desea continuar comprando? 1=SI 2=NO\n:"))
        if cont==1:
            compra()
        else:
            print("Hasta luego")    
    else:
        print("El numeo ingresado no corresponde al sitio, ingrese nuevamente")   
        silver()
def datos_personas():
    rut=input("Ingrese su rut sin guion ni codigo verificador\n:")
    if rut <99999999:
        print("resgitro exitoso")
    else:
        print("El rut es invalido, intente de nuevo")
compra() 
