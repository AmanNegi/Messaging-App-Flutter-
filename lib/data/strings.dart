//auth related strings--

import 'package:google_fonts/google_fonts.dart';

String dialogVerificationBodyText =
    "An verification was sent to your email. Kindly verify to continue. If you have verified wait for a while while it syncs with your device.";
String dialogVerificationTitle = "Verify your email to proceed";
String login = "Login";
String signUp = "SignUp";
String loginHelperText = "New User? SignUp";
String signUpHelperText = "Already have an account? Log in";

// Demo Image Strings--

String demoImage =
    "https://image.freepik.com/free-vector/plexus-modern-design-connections-network-futuristic_1048-11932.jpg";

 String getFontFromString(String text) {
  if (text == 'Ubuntu_regular') {
    return GoogleFonts.ubuntu().fontFamily;
  } else if (text == 'Quicksand_regular') {
    return GoogleFonts.quicksand().fontFamily;
  } else if (text == 'Exo_regular') {
    return GoogleFonts.exo().fontFamily;
  } else if (text == 'Comfortaa_regular') {
    return GoogleFonts.comfortaa().fontFamily;
  } else if (text == 'Raleway_regular') {
    return GoogleFonts.raleway().fontFamily;
  }
}
