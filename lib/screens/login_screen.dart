import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    bool _obscureText = false;

    @override
    void initState(){
      super.initState();
      _obscureText=true;
    }    

  @override
  Widget build(BuildContext context) {

    //para obtener el tamaño de la pantalla: :D

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
                child: RiveAnimation.asset("assets/animated_login_character.riv")
                ),
              
              // espacio entre oso y texto
              SizedBox(height: 10,),
          
              // campo de texto
              TextField(
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
                       });
                    }, )
                ),
              ),            
          
          
            ],
          ),
        )),
    );
  }
}