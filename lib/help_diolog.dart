import 'package:flutter/material.dart';

void showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 39, 13, 65),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'How to Play',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Swipe in any direction to move all tiles',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              '• When two tiles with the same number collide, they merge',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              '• After every move, a new tile (2 or 4) appears on the board',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              '• Combine tiles strategically to reach the 2048 tile',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              '• If no moves are left and the board is full, the game ends',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              '• Try to score as high as possible before the board fills up',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Got it!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    },
  );
}
