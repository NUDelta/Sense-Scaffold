//
//  GetInfoInterfaceController.swift
//  sense
//
//  Created by Aaron Loh on 20/10/15.
//  Copyright © 2015 Aaron Loh. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class GetInfoInterfaceController: WKInterfaceController,WCSessionDelegate {

    @IBOutlet var hotspotIDLabel: WKInterfaceLabel!
    
    @IBOutlet var question1button: WKInterfaceButton!
 

    @IBOutlet var question2button: WKInterfaceButton!
    
    @IBOutlet var question3button: WKInterfaceButton!

    var hotspotID = ""
    var questionArr = [String]()
    var incompleteFieldArr = [String]()
    var completedInfoDict = [String:String]()
    var tag = ""
    // session for communicating with iPhone
    let watchSession = WCSession.defaultSession()
    
    @IBOutlet var infoLabel: WKInterfaceLabel!
    
    @IBAction func question1ButtonAction() {
        //pushControllerWithName("QuestionController", context: question1Title)
        var answerArray:[String]
        switch(tag){
        case("food"):
            switch(question1Title){
            case("What's here?"):
                answerArray = ["food", "career fair", "concert"]
            case("duration?"):
                answerArray = ["0.5 hours", "1 hour", "2 hours"]
            case("type?"):
                answerArray = ["pizza", "bagels", "coffee"]
            default:
                answerArray = []
                break
            }
        case("infosession"):
            switch(question1Title){
            case("company?"):
                answerArray = ["Google", "Microsoft", "Facebook"]
            case("positions?"):
                answerArray = ["internship", "fulltime"]
            default:
                answerArray = []
                break
            }
        case("music"):
            switch(question1Title){
            case("genre?"):
                answerArray = ["jazz", "classical", "pop"]
            default:
                answerArray = []
                break
            }
        default:
            answerArray = []
            break;
        }
        handleUserAnswer(answerArray,index: 0);
    }

    @IBAction func question2ButtonAction() {
        //pushControllerWithName("QuestionController", context: question2Title)
        var answerArray:[String]
        switch(tag){
        case("food"):
            switch(question2Title){
            case("What's here?"):
                answerArray = ["food", "career fair", "concert"]
            case("duration?"):
                answerArray = ["0.5 hours", "1 hour", "2 hours"]
            case("type?"):
                answerArray = ["pizza", "bagels", "coffee"]
            default:
                answerArray = []
                break
            }
        case("infosession"):
            switch(question2Title){
            case("company?"):
                answerArray = ["Google", "Microsoft", "Facebook"]
            case("positions?"):
                answerArray = ["internship", "fulltime"]
            default:
                answerArray = []
                break
            }
        case("music"):
            switch(question2Title){
            case("genre?"):
                answerArray = ["jazz", "classical", "pop"]
            default:
                answerArray = []
                break
            }
        default:
            answerArray = []
            break;
        }
        handleUserAnswer(answerArray,index: 1);
    }
    
    @IBAction func question3ButtonAction() {
        //pushControllerWithName("QuestionController", context: question3Title)
        var answerArray:[String]
        
        switch(tag){
        case("food"):
            switch(question3Title){
            case("What's here?"):
                answerArray = ["food", "career fair", "concert"]
            case("duration?"):
                answerArray = ["0.5 hours", "1 hour", "2 hours"]
            case("type?"):
                answerArray = ["pizza", "bagels", "coffee"]
            default:
                answerArray = []
                break
            }
        case("infosession"):
            switch(question3Title){
            case("company?"):
                answerArray = ["Google", "Microsoft", "Facebook"]
            case("positions?"):
                answerArray = ["internship", "fulltime"]
            default:
                answerArray = []
                break
            }
        case("music"):
            switch(question3Title){
            case("genre?"):
                answerArray = ["jazz", "classical", "pop"]
            default:
                answerArray = []
                break
            }
        default:
            answerArray = []
            break;
        }
        
        
        handleUserAnswer(answerArray,index: 2);
    }
    
    
    func handleUserAnswer(answerArray : [String], index : Int){
        presentTextInputControllerWithSuggestions(answerArray, allowedInputMode: WKTextInputMode.Plain
            , completion: {completionDictionary in
                print ("completion handler for answer entered")
                if let answerArr = completionDictionary {
                    if (answerArr.count > 0){
                        let answer = answerArr[0] as! String
                        print (answer + self.hotspotID + self.incompleteFieldArr[index])
                        self.updateHotspotInformation(self.incompleteFieldArr[index], info: answer)
                        
                        self.completedInfoDict[self.incompleteFieldArr[index]] = answer
                        self.questionArr.removeAtIndex(index)
                        self.incompleteFieldArr.removeAtIndex(index)
                        
                        self.updateUI()
                    }
                }
                
        })
    }
    
    var question1Title = ""
    var question2Title = ""
    var question3Title = ""
    
    func updateHotspotInformation(infotype: String, info:String){
        let message = ["command": "updateObject", "objectID": hotspotID, infotype:info]
        print(message)
        
        watchSession.sendMessage(message, replyHandler: {replyDictionary in
            print("reply handler called for updatingInfo")
            print(replyDictionary)
        }, errorHandler: {error in
                print("error in updating object from user input \(error)")})
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        watchSession.delegate=self
        watchSession.activateSession()
        print(context)
        guard let returnedQuestionArrayFromParse = context as! Array<Dictionary<String,AnyObject>>? else {return}
        
        var dictEntry:Dictionary<String,AnyObject>
        if(returnedQuestionArrayFromParse.count > 0){
            dictEntry = returnedQuestionArrayFromParse[0]
        }else{
            hotspotIDLabel.setText("No locations")
            question2button.setHidden(true)
            question1button.setHidden(true)
            question2button.setHidden(true)
            question3button.setHidden(true)
            return
        }
        
        let identifier = dictEntry["id"] as! String
        
        hotspotIDLabel.setText(identifier)
        hotspotID = identifier
        print(dictEntry)
        tag = dictEntry["tag"] as! String
        
        for (field, entry) in dictEntry{
            if (field != "latitude" && field != "longitude" && field != "date" && field != "id"){
                let castEntry = entry as! String
                if (castEntry.characters.last! == "?"){
                    questionArr.append(castEntry)
                    incompleteFieldArr.append(field)
                }else{
                    completedInfoDict[field] = castEntry
                }
            }
        }
        
        updateUI()
    }
    
    func updateUI(){
        
        print(completedInfoDict)
        if(completedInfoDict.count == 0){
            infoLabel.setHidden(true)
        }else{
            infoLabel.setHidden(false)
            var info = ""
            for (key, val) in completedInfoDict {
                info += key + ": " + val + "\n"
            }
            
            infoLabel.setText(info)
        }
        
        
        let numInfoFieldsRequired = questionArr.count
        
        switch(numInfoFieldsRequired){
        case 0:
            question1button.setHidden(true)
            question2button.setHidden(true)
            question3button.setHidden(true)
            break
        case 1:
            question1button.setTitle(questionArr[0])
            question1Title = questionArr[0]
            question2button.setHidden(true)
            question3button.setHidden(true)
            break
        case 2:
            question1button.setTitle(questionArr[0])
            question1Title = questionArr[0]
            question2button.setTitle(questionArr[1])
            question2Title = questionArr[1]
            question3button.setHidden(true)
            break
        case 3:
            question1button.setTitle(questionArr[0])
            question1Title = questionArr[0]
            question2button.setTitle(questionArr[1])
            question2Title = questionArr[1]
            question3button.setTitle(questionArr[2])
            question3Title = questionArr[2]
            break
        default:
            question1button.setTitle(questionArr[0])
            question1Title = questionArr[0]
            question2button.setTitle(questionArr[1])
            question2Title = questionArr[1]
            question3button.setTitle(questionArr[2])
            question3Title = questionArr[2]
            break
            
        }

    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
