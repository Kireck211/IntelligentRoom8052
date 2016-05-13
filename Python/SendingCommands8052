import serial
#Can be Downloaded from this Link
#https://pypi.python.org/pypi/pyserial

#Global Variables
ser = 0
comandos = ["Prende luces", "Apaga luces", "Prende n luces", "Apaga n luces", "Abre puerta", "Cierra puerta", "Cambia hora", "Salir"]
existe_comando = False
leds = [0,0,0,0,0,0,1,0]
ascii = ""


def imprime_comandos():
    i = 1
    print "Los comandos son:"
    for comando in comandos:
        print str(i) + " - ", comando
        i += 1
print ""

#Function to Initialize the Serial Port
def init_serial():
    global ser          #Must be declared in Each Function

    ser = serial.Serial(
        port='COM60',
        baudrate=9600,
        parity=serial.PARITY_ODD,
        stopbits=serial.STOPBITS_TWO,
        bytesize=serial.SEVENBITS
    )
    ser.timeout = 10
    ser.isOpen()

    # print port open or closed
    if ser.isOpen():
        print 'Open: ' + ser.portstr

    print "Hola yo soy Jarvis de IntelligentRoom8051, fui creado por Luis Alberto Anton Delgadillo y Erick De Santiago Anaya y la ayuda de Miguel Hernandez Sandoval"
    imprime_comandos()

    print ""
    comando = raw_input("Escribe tu comando por favor \n> ")
    comando = comando.capitalize()

    while(comando!="Salir"):
        numero_ascii = 0
        ascii = ""
        existe_comando = False
        for com in comandos:
            if(com == comando):
                existe_comando = True
                break
        if(not existe_comando):
            print ""
            print "Ese no es un comando disponible, vuelve a internarlo por favor"
            print ""
            comando = raw_input("Escribe tu comando por favor \n> ")
            comando = comando.capitalize()
            continue
        else:
            if (comando == "Prende luces"):
                comando = "LE_#"

            elif (comando == "Apaga luces"):
                comando = "LE@#"

            elif(comando == "Prende n luces"):  
                respuesta = raw_input("\nPrender luz 1?\n>")
                if (respuesta == "si" or respuesta == 's' or respuesta == "Si"):
                    leds[0] = 1
                respuesta = raw_input("\nPrender luz 2?\n>")
                if (respuesta == "si" or respuesta == 's' or respuesta == "Si"):
                    leds[1] = 1
                respuesta = raw_input("\nPrender luz 3?\n>")
                if (respuesta == "si" or respuesta == 's' or respuesta == "Si"):
                    leds[2] = 1
                respuesta = raw_input("\nPrender luz 4?\n>")
                if (respuesta == "si" or respuesta == 's' or respuesta == "Si"):
                    leds[3] = 1
                respuesta = raw_input("\nPrender luz 5?\n>")
                if (respuesta == "si" or respuesta == 's' or respuesta == "Si"):
                    leds[4] = 1
                potencia = 1
                numero = 0
                for x in leds:
                    if (x == 1):
                        numero += potencia
                    potencia *=2
                print numero
                ascii = str(unichr(numero))
                comando = "LE"+ascii+"#"

            elif(comando == "Apaga n luces"): 
                respuesta = raw_input("\nApagar luz 1?\n>")
                if (respuesta == "si" or respuesta == 's' or respuesta == "Si"):
                    leds[0] = 0
                respuesta = raw_input("\nApagar luz 2?\n>")
                if (respuesta == "si" or respuesta == 's' or respuesta == "Si"):
                    leds[1] = 0
                respuesta = raw_input("\nApagar luz 3?\n>")
                if (respuesta == "si" or respuesta == 's' or respuesta == "Si"):
                    leds[2] = 0
                respuesta = raw_input("\nApagar luz 4?\n>")
                if (respuesta == "si" or respuesta == 's' or respuesta == "Si"):
                    leds[3] = 0
                respuesta = raw_input("\nApagar luz 5?\n>")
                if (respuesta == "si" or respuesta == 's' or respuesta == "Si"):
                    leds[4] = 0

                potencia = 1
                numero = 0
                for x in leds:
                    if (x == 1):
                        numero += potencia
                    potencia *=2
                ascii = str(unichr(numero))
                comando = "LE"+ascii+"#"

            elif(comando == "Abre puerta"):
                comando = "E1#"

            elif(comando == "Cierra puerta"):
                comando = "E0#"

            elif(comando == "Cambia hora"):
                hora = raw_input("Escriba la hora con el formato de 24hrs y hh:mm\n>")
                comando = "C" + hora[0:2]+ hora[3:] + "#"
            ser.write(comando)
            print ""
            imprime_comandos()
            comando = raw_input("Escribe tu comando por favor\n> ")
            comando = comando.capitalize()


#Call the Serial Initilization Function, Main Program Starts from here
init_serial()
