// Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   const SizedBox(
//                     height: 24,
//                   ),
//                   const Text(
//                     'Movement Controls',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 24,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       GameButton(
//                         icon: Icons.arrow_upward,
//                         onLongPressDown: () {
//                           send("forward");
//                         },
//                         onLongPressEnd: () {
//                           send("stop");
//                         },
//                       ),
//                     ],
//                   ),
//                   Expanded(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         GameButton(
//                           icon: Icons.arrow_back,
//                           onLongPressDown: () {
//                             send("left");
//                           },
//                           onLongPressEnd: () {
//                             send("stop");
//                           },
//                         ),
//                         const SizedBox(
//                           width: 100.0,
//                         ),
//                         GameButton(
//                           icon: Icons.arrow_forward,
//                           onLongPressDown: () {
//                             send("right");
//                           },
//                           onLongPressEnd: () {
//                             send("stop");
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       GameButton(
//                         icon: Icons.arrow_downward,
//                         onLongPressDown: () {
//                           send("backward");
//                         },
//                         onLongPressEnd: () {
//                           send("stop");
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 24,
//                   ),
//                 ],
//               ),