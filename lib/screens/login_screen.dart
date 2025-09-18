import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

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


    @override
    void initState(){
      super.initState();
      _obscureText=true;
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

                  }
              )),
              
              // espacio entre oso y texto
              SizedBox(height: 10,),
          
              // campo de texto
              TextField(
                onChanged: (value) {
                  if (isHandsUp != null) {
                    isHandsUp!.change(false);
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
          
              // campo de texto
              TextField(
                onChanged: (value) {
                  if (isHandsUp != null) {
                    isHandsUp!.change(true);
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
}