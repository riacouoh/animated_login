import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

      //4.1 Controller <-- this guy isn't just nosy, he's a stalker
      final emailCtrl = TextEditingController();
      final passCtrl = TextEditingController();

      //4.2 Errores para mostrar en la UI. Your regular user should not be seeing SQL errors. Pls.
      String? emailError;
      String? passError;


        bool isLoading = false; // NUEVO - deshabilita el botón y muestra spinner

      // NUEVO - Validación dinámica de email
      String? firstEmailError(String text) {
        final value = text.trim();
        if (value.isEmpty) return null; // no mostrar error si está vacío
        final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
        if (!emailRegex.hasMatch(value)) return 'Email no válido';
        return null;
      }

      // NUEVO - Validación dinámica de contraseña
      String? firstPasswordError(String text) {
        final p = text;
        if (p.isEmpty) return 'La contraseña no puede estar vacía';
        if (p.length < 8) return 'Mínimo 8 caracteres';
        if (!RegExp(r'[A-Z]').hasMatch(p)) return 'Debe incluir una mayúscula';
        if (!RegExp(r'[a-z]').hasMatch(p)) return 'Debe incluir una minúscula';
        if (!RegExp(r'\d').hasMatch(p)) return 'Debe incluir un número';
        if (!RegExp(r'[^A-Za-z0-9]').hasMatch(p)) return 'Debe incluir un caracter especial';
        return null;
      }

      //4.3 Validadores <-- these guys are the bouncers at the club
      bool isValidEmail(String email) {
        
        final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
        return re.hasMatch(email);

      }

      bool isValidPassword(String pass) {
          // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
          final re = RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
          );
          return re.hasMatch(pass);
        }

    //4.4 Acción al botón

    Future<void> _onLogin() async {

      if (isLoading) return; // NUEVO - evita que se presione varias veces

      final email = emailCtrl.text.trim();
      final password = passCtrl.text;

      final eError = firstEmailError(email); // NUEVO - usa nuevo validador
      final pError = firstPasswordError(password); // NUEVO - usa nuevo validador

      setState(() {
        emailError = eError;
        passError = pError;
        isLoading = true; // NUEVO - activa estado de carga
      });

      // Normalizar el estado antes del trigger
      FocusScope.of(context).unfocus();
      _typingDebounce?.cancel();
      isChecking?.change(false);
      isHandsUp?.change(false);
      numLook?.value = 50.0; // mirada neutral

      // NUEVO - Esperar un frame antes de disparar trigger (soluciona doble tap)
      await SchedulerBinding.instance.endOfFrame;

      // NUEVO - Simular "envío" de datos con un pequeño delay
      await Future.delayed(const Duration(seconds: 1));

      if (eError == null && pError == null) {
        trigSuccess?.fire(); // NUEVO - trigger éxito
        } else {
          trigFail?.fire(); // NUEVO - trigger fallo
          }

      if (mounted) {
        setState(() {
          isLoading = false; // NUEVO - reactivar botón después del envío
          });
        }
      }

    
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
                    trigSuccess = controller!.findSMI("trigSuccess");
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

                // 4.8 enlazar controller al TextField
                controller: emailCtrl,
                
                onChanged: (value) {
                
                  setState(() {
                      emailError = firstEmailError(value);
                    });
                  
                //2.4 Implementing numLook (moving eyes)
                  
                  if (isChecking != null) {
                    isChecking!.change(true);
                    final look = ((value.length / 80.0) * 100.0).clamp(0.0, 100.0).toDouble();
                    numLook?.value = look;
                  }

                    //3.3 Debounce: si vuelve a teclear, reinicia el contador
                  _typingDebounce?.cancel(); //cancela cualquier timer existente

                  _typingDebounce = Timer(const Duration(milliseconds: 2000), () {
                  
                    if(!mounted) {
                      isChecking?.change(false);
                      numLook?.value = 50.0;// <-- si la pantalla se cierra, stop execution
                    }
                      //mirada neutra
                    isChecking?.change(false);

                  });
                  
                },
                
                keyboardType: TextInputType.emailAddress, // <-- para que aparezca @ en móviles
                decoration: InputDecoration(
                  //4.9 mostrar el texto del error
                  errorText: emailError,
                  hintText: "E-Mail",
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
              ),

              if (emailCtrl.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      Icon(
                        emailError == null ? Icons.check_circle : Icons.error,
                        size: 18,
                        color: emailError == null ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        emailError ?? 'Email válido',
                        style: TextStyle(
                          color: emailError == null ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
          

              const SizedBox(height: 10,),
          
              // campo de texto de CONTRASEÑA
              TextField(
                focusNode: passFocus,
                controller: passCtrl,
                onChanged: (value) {

                  setState(() {
                    passError = firstPasswordError(value);
                  });

                  if (isHandsUp != null) {
                    isHandsUp!.change(true);
                  }

                },
                obscureText: _obscureText,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.key),
                    errorText: passError,
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

               // NUEVO - Checklist dinámico debajo del password
              if (passCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      Icon(
                        passError == null ? Icons.check_circle : Icons.error,
                        size: 18,
                        color: passError == null ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        passError ?? 'Contraseña válida',
                        style: TextStyle(
                          color:
                              passError == null ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
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
                color: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: isLoading ? null : _onLogin, // NUEVO
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
              ),

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
    //4.11 limpieza de los controllers
    emailCtrl.dispose();
    passCtrl.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }

}