import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

//3.1 importar librería para timer
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    bool _obscureText = false;


    //cerebro de la lógica de las animaciones
    
    StateMachineController? controller;

    //STATE MACHINE INPUT (SMI)
    
      SMIBool? isChecking;      //<-- modo "chismoso"
      SMIBool? isHandsUp;       //<-- tapa sus ojos
      SMITrigger? trigSuccess;  // happy bear. elated bear
      SMITrigger? trigFail;     // sad bear :(

      // 2.1 variable p/recorrido de ojos
      SMINumber? numLook;

      //1) FocusNode
      final emailFocus = FocusNode();
      final passFocus = FocusNode();

    // 3.2 timer para detener la mirada al dejar de teclear
      Timer? _typingDebounce;


    //2. Listeners (GOSSIP, NOSEY, METICHE!!!

    @override
    void initState(){
      super.initState();
      _obscureText=true;

      emailFocus.addListener(() {
      
      if (emailFocus.hasFocus) {
          //manos abajo en email
          isHandsUp?.change(false);

          //2.2 mirada neutral del oso when email is in focus
          numLook?.value = 50.0; // <-- value must be a double as per RIVE requirements
          isHandsUp?.change(false);
      }
      });

      passFocus.addListener(() {
        //manos arriba en password
        isHandsUp?.change(passFocus.hasFocus);
      });

    }    

  @override
  Widget build(BuildContext context) {

    //para obtener el tamaño de la pantalla: :D (consulta)

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      //evia nudge o cámaras frontales
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  "assets/animated_login_character.riv",
                  stateMachines: ["Login Machine"],
                  //al iniciarse
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(artboard, "Login Machine");

                    //verificar que inició bien
                    if (controller==null) return;
                    artboard.addController(controller!);
                    isChecking = controller!.findSMI("isChecking");
                    isHandsUp = controller!.findSMI("isHandsUp");
                    trigSuccess = controller!.findSMI("trigSucess");
                    trigFail = controller!.findSMI("trigFail");

                    // 2.3 enlazar variable numLook con la animación
                    numLook = controller!.findSMI("numLook");

                  }
              )),
              
              // espacio entre oso y texto
              SizedBox(height: 10,),
          

              // EMAIL
              TextField(
                //asign email focusnode from override to textfield (call your nosy neighbors)
                focusNode: emailFocus,
                
                onChanged: (value) {
                
                //2.4 Implementing numLook (moving eyes)
                  if (isHandsUp != null) {
                    //"Estoy escribiendo"
                    isChecking!.change(true);

                    //ajuste de limites de 0 a 100
                      //80.0 = medida de calibración
                    final look = (value.length / 80.0 * 100.0).clamp(0.0, 100.0);
                    numLook?.value = look;

                    //3.3 Debounce: si vuelve a teclear, reinicia el contador
                    _typingDebounce?.cancel(); //cancela cualquier timer existente

                    _typingDebounce = Timer(const Duration(milliseconds: 2000), () {
                      if(!mounted) {
                        return; // <-- si la pantalla se cierra, stop execution
                      }
                      //mirada neutra
                      isChecking?.change(false);

                    });
                  }
                  
                  if(isChecking == null) return;
                  //activa modo chismoso
                  isChecking!.change(true);
                },
                
                keyboardType: TextInputType.emailAddress, // <-- para que aparezca @ en móviles
                decoration: InputDecoration(
                  hintText: "E-Mail",
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
              ),
          
              const SizedBox(height: 10,),
          
              // campo de texto de CONTRASEÑA
              TextField(
                focusNode: passFocus,
                onChanged: (value) {
                  if (isHandsUp != null) {
                    //isHandsUp!.change(true);
                  }

                  if(isChecking == null) return;

                  //activa modo chismoso
                  isChecking!.change(false);


                },
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off,),
                      onPressed: () {
                      setState(() {
                         _obscureText = !_obscureText;
                         isHandsUp!.change(false);
                       });
                    }, )
                ),
              ),
              SizedBox(height: 10,),

              //texto reestablecer contraseña
              SizedBox(
                width: size.width,
                child: const Text(
                  "Forgot password?",
                  textAlign: TextAlign.right,
                  style: TextStyle( decoration: TextDecoration.underline),
                ),
              ),

              //login

              const SizedBox(height: 10,),

              //botón estilo android
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                onPressed: () {},
                child: Text("Login,",
                  style: TextStyle(color: Colors.white),),),
              const SizedBox(height: 10,),

              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Create an account"),
                    TextButton(onPressed: () {}, 
                      child: const Text("Register", 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.underline)))
                  ],
                ),
              )
          
            ],
          ),
        )),
    );
  }


  //liberación, limpieza, muerte de los focos (recursos)
  @override
  void dispose() {
    // TODO: implement dispose
    emailFocus.dispose();
    passFocus.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }

}