import 'package:flutter/material.dart';

Widget bottomBar(Function setIndexCurrent,int indexCurrent){
  return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Especial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc),
            label: 'Rutas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dangerous),
            label: '2° Vuelta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vaccines),
            label: 'LLamadas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.yard),
            label: 'Nuevo',
          ),
        ],
        elevation: 10,
        currentIndex: indexCurrent,
        selectedItemColor: Colors.amber[800],
        onTap:(value)=>setIndexCurrent(value),
      );
}