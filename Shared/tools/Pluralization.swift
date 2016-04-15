//
//  Pluralization.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 18/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

// This pluralization class is equivalent to Flexions' Pluralization.php
// You should pass lower case string for better results.
// Eg: Thanks to this symetric implementation Aggregated CreateAlias operations
// can be interpreted as CreateAliases


import Foundation

/*

let words=["megaquiz","quiz","Quiz","fly","FLY","Fly","alias","user","woman","Woman","man","money","Fish","fish","tomato","Tomato","axis","axe","test","Parenthesis"]
for word in words{
    let pluralized=Pluralization.pluralize(word.lowercaseString)
    let singularized=Pluralization.singularize(pluralized)
    let result = ( word.lowercaseString == singularized.lowercaseString ? "" : "!" )
    print("\(word) -> \(pluralized) -> \(singularized) \(result)")
}
*/

class Pluralization{

    static let uncountables=["equipment", "information", "rice", "money", "species", "series", "fish", "sheep"]
    
    static let irregulars=["person":"people","man":"men","child":"children","sex":"sexes","move":"moves"]
    
    static var plurals:[(rule:String,replacement:String)]{
        get{
            var plurals=[(rule:String,replacement:String)]()
            plurals.append(("(quiz)$","$1zes"))
            plurals.append(("^(ox)$","$1en"))
            plurals.append(("([m|l])ouse$","$1ice"))
            plurals.append(("(matr|vert|ind)ix|ex$","$1ices"))
            plurals.append(("(x|ch|ss|sh)$","$1es"))
            plurals.append(("([^aeiouy]|qu)ies$","$1y"))
            plurals.append(("([^aeiouy]|qu)y$","$1ies"))
            plurals.append(("(hive)$","$1s"))
            plurals.append(("(?:([^f])fe|([lr])f)$","$1$2ves"))
            plurals.append(("sis$","ses"))
            plurals.append(("([ti])um$","$1a"))
            plurals.append(("(buffal|tomat)o$","$1oes"))
            plurals.append(("(bu)s$","$1ses"))
            plurals.append(("(alias|status)","$1es"))
            plurals.append(("(octop|vir)us$","$1i"))
            plurals.append(("(ax|test)is$","$1es"))
            plurals.append(("s$","s"))
            plurals.append(("$","s"))
            return plurals
        }
    }
    
    
    static var singulars:[(rule:String,replacement:String)]{
        get{
            var singulars=[(rule:String,replacement:String)]()
            singulars.append(("(quiz)zes$","$1"))
            singulars.append(("(matr)ices$","$1ix"))
            singulars.append(("(vert|ind)ices$","$1ex"))
            singulars.append(("^(ox)en","$1"))
            singulars.append(("(alias|status)es$","$1"))
            singulars.append(("([octop|vir])i$","$1us"))
            singulars.append(("(cris|ax|test)es$","$1is"))
            singulars.append(("(shoe)s$","$1"))
            singulars.append(("(o)es$","$1"))
            singulars.append(("(bus)es$","$1"))
            singulars.append(("([m|l])ice$","$1ouse"))
            singulars.append(("(x|ch|ss|sh)es$","$1"))
            singulars.append(("(m)ovies$","$1ovie"))
            singulars.append(("(s)eries$","$1eries"))
            singulars.append(("([^aeiouy]|qu)ies$","$1y"))
            singulars.append(("([lr])ves$","$1f"))
            singulars.append(("(tive)s$","$1"))
            singulars.append(("(hive)s$","$1"))
            singulars.append(("([^f])ves$","$1fe"))
            singulars.append(("(^analy)ses$","$1sis"))
            singulars.append(("((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$","$1$2sis"))
            singulars.append(("([ti])a$","$1um"))
            singulars.append(("(n)ews$","$1ews"))
            singulars.append(("s$",""))
            return singulars
        }
    }
    
    static func pluralize(word:String)->String{
        
        let lowerCasedWord=word//PString.strtolower(word)
        
        for uncountable in Pluralization.uncountables {
            if let sub=PString.substr(lowerCasedWord,(-1 * PString.strlen(uncountable))){
                if sub == uncountable{
                    return word
                }
            }
        }
        
        for (singular,plural) in Pluralization.irregulars {
            var arr=[String]()
            if PString.preg_match("(\(singular))$", word,&arr) == 1 {
                return PString.preg_replace("(\(singular))$",plural, word)
            }
        }
        
        for entry in plurals {
            var arr=[String]()
            if  PString.preg_match(entry.rule, word,&arr) > 0 {
                return PString.preg_replace(entry.rule, entry.replacement,word);
            }
        }
        
        return "NOT_PLURALIZED";
    }
    
    
    static func singularize(word:String)->String{
        
        let lowerCasedWord = word//PString.strtolower(word);
        for uncountable in Pluralization.uncountables {
            if let sub=PString.substr(lowerCasedWord, (-1 * PString.strlen(uncountable))) {
                if sub == uncountable{
                    return word
                }
            }
        }
        
        for (plural,singular) in Pluralization.irregulars {
            var arr=[String]()
            if PString.preg_match("(\(singular))$", word,&arr) == 1 {
                return PString.preg_replace("(\(singular))$",plural, word)
            }
        }
        
        for (rule,replacement) in singulars {
            var arr=[String]()
            if  PString.preg_match(rule, word,&arr) > 0 {
                return PString.preg_replace(rule, replacement,word);
            }
        }
        
        return "NOT_SINGULARIZED";
    }
    
}
