//
//  ConsentDocument.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 22/05/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import ResearchKit

class ConsentDocument: ORKConsentDocument {
    // MARK: Properties
    
    let consentTextsArray = [
        "Duis euismod sollicitudin elementum. Interdum et malesuada fames ac ante ipsum primis in faucibus. Sed at pharetra sapien. Pellentesque cursus laoreet interdum. Nunc mi sapien, congue vel eleifend in, luctus sit amet massa. Nam tempus metus nec mauris bibendum, vel suscipit quam aliquet. Vestibulum sagittis mi et tempus iaculis. Integer varius eros non sagittis elementum. Proin dictum magna sit amet nulla volutpat posuere eget ac mi. Cras aliquam tristique velit nec porttitor. Integer nulla ligula, vestibulum a ullamcorper non, volutpat non nibh. Integer auctor ipsum id leo pharetra, vitae dapibus augue sagittis. Proin ut diam non orci vulputate rutrum a et nulla. Maecenas in varius augue, eu pretium metus. In auctor ornare augue ac sodales.",
        "Aenean in ligula quis arcu rhoncus tristique. Donec ut nisl suscipit augue ornare venenatis. Suspendisse commodo nibh dignissim, congue justo quis, ultrices sapien. Aliquam at lacinia ante. Sed venenatis quam eget dui lobortis, non ullamcorper tellus molestie. Quisque tempus fringilla velit, et viverra odio accumsan quis. Suspendisse potenti. Nullam ac dolor nunc. Pellentesque nec scelerisque risus. Interdum et malesuada fames ac ante ipsum primis in faucibus. Phasellus consectetur efficitur rutrum. Suspendisse in arcu id ex luctus aliquam quis at quam.",
        "Maecenas quis varius massa. Nam in dapibus turpis, ut varius eros. Proin a ex enim. Sed faucibus magna vel tincidunt facilisis. Donec id ligula vel mi suscipit sollicitudin. Nulla non magna blandit, semper augue vel, sagittis dui. Curabitur quis rutrum ex. Sed ipsum odio, mattis et dignissim sit amet, volutpat et turpis. Sed quis placerat orci. Duis vitae bibendum diam.",
        "Sed nec tortor sapien. Quisque tempor scelerisque vulputate. Nulla eget consequat urna. Aliquam tempus sagittis orci vel tempus. Mauris porta ante sed maximus iaculis. Etiam elit purus, pretium nec ipsum non, aliquam commodo erat. Aliquam sagittis, nibh at porta pellentesque, libero purus finibus nulla, sed consectetur tellus sem non nisl. Duis eu sollicitudin orci. Quisque tincidunt feugiat sapien ac accumsan. Nullam vitae fringilla quam."
    ]
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        title = NSLocalizedString("Research Health Study Consent Form", comment: "")
        
        let sectionTypes: [ORKConsentSectionType] = [
            .Overview,
            .DataGathering,
            .Privacy,
            .StudyTasks,
        ]
        
        sections = zip(sectionTypes, consentTextsArray).map { sectionType, consentText in
            let section = ORKConsentSection(type: sectionType)
            
            let localizedConsent = NSLocalizedString(consentText, comment: "")
            let localizedSummary = localizedConsent.componentsSeparatedByString(".")[0] + "."
            
            section.summary = localizedSummary
            section.content = localizedConsent
            
            return section
        }
        
        let signature = ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature")
        addSignature(signature)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ORKConsentSectionType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .Overview:
            return "Overview"
            
        case .DataGathering:
            return "DataGathering"
            
        case .Privacy:
            return "Privacy"
            
        case .DataUse:
            return "DataUse"
            
        case .TimeCommitment:
            return "TimeCommitment"
            
        case .StudySurvey:
            return "StudySurvey"
            
        case .StudyTasks:
            return "StudyTasks"
            
        case .Withdrawing:
            return "Withdrawing"
            
        case .Custom:
            return "Custom"
            
        case .OnlyInDocument:
            return "OnlyInDocument"
        }
    }
}