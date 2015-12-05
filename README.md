# Sense-Scaffold

## Structure
1. Apple Watch Code
Interface Controller
  * reporting location (Note, when you first set this up, you need to grant the app access to location data)
  * fetching hotspots from Parse along with associated questions
  * notification handling code
  * debug tools: print to iphone: prints text to iphone
GetInfoInterfaceController
  * This is where the user gets to answer questions about a certain hotspot that has been detected nearby
  
2. iPhone Code
App Delegate
  *This is where you set up notifications
ViewController
  *This is where the Parse interactions happen
  *main function is the session function, which deals with messages that are sent from the apple watch
  *Also offers debugging tools like simulating a notification, printing to the iPhone app
  
3. Parse Cloud Code
  *This is where you set up the questions that Parse asks about each hotspot. This code handles what happens when a user reports a hotspot.
  For instance, if a user reports that there is an infosession nearby, this is where you can decide what kinds of information you want Parse
  to fill in about that infosession
  
##Instructions on running the code
1. Download the folder to your local machine
2. Open the xcode project
3. Run the app on the simulator (if you do this, run the complication scheme) or your actual device (you will need a paired apple watch)
