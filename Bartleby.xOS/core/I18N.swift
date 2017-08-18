//
//  I18N.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 18/08/2017.
//


import Foundation

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif


public struct Language{
    let code:String
    let localizedDisplayName:String
    let displayName:String
}

public struct I18N {

    fileprivate static var _languages:[Language]?

    fileprivate static var _languageCodes:[String]?

    fileprivate static var _localizedLanguageNames:[String]?

    fileprivate static var _languageNames:[String]?

    public static var defaultLanguageCode:String {
        let currentLocale:NSLocale = NSLocale(localeIdentifier: NSLocale.current.identifier)
        return currentLocale.object(forKey: NSLocale.Key.languageCode) as! String
    }

    public static  func languageName(forCode:String)->String?{
        for language in I18N.languages{
            if language.code == forCode{
                return language.displayName
            }
        }
        return nil
    }

    public static  func localizedLanguageName(forCode:String)->String?{
        for language in I18N.languages{
            if language.code == forCode{
                return language.localizedDisplayName
            }
        }
        return nil
    }

    // The Language names in their own locale
    public static var languageNames:[String] {
        if let names = I18N._languageNames{
            return names
        }
        I18N._languageNames = I18N.languages.map({ (language) -> String in
            return language.displayName
        })
        return I18N._languageNames!
    }


    // The localized Language names
    public static var localizedLanguageNames:[String] {
        if let names = I18N._localizedLanguageNames{
            return names
        }
        I18N._localizedLanguageNames = I18N.languages.map({ (language) -> String in
            return language.localizedDisplayName
        })
        return I18N._localizedLanguageNames!
    }

    // the language codes
    public static var languageCodes:[String] {
        if let codes = I18N._languageCodes{
            return codes
        }
        I18N._languageCodes = I18N.languages.map({ (language) -> String in
            return language.code
        })
        return I18N._languageCodes!
    }


    /// A sorted language list.
    public static var languages:[Language]{
        if let listedLanguages = I18N._languages{
            return listedLanguages
        }
        let currentLocale:NSLocale = NSLocale(localeIdentifier: NSLocale.current.identifier)
        var languages = [Language]()
        for localeIdentifier in NSLocale.availableLocaleIdentifiers{
            let locale = NSLocale(localeIdentifier: localeIdentifier)
            // We must stay compliant with macOS 10.11
            // so we cannot use `locale.localizedString(forLanguageCode: locale.languageCode)`
            if let lang = locale.displayName(forKey: NSLocale.Key.languageCode, value: localeIdentifier)?.capitalized{
                if let localizedLang = currentLocale.displayName(forKey: NSLocale.Key.languageCode, value: localeIdentifier)?.capitalized{
                    let languageCode = locale.object(forKey: NSLocale.Key.languageCode) as! String

                    if !languages.contains(where: { (language) -> Bool in
                        return language.code == languageCode
                    }){
                         let language =  Language(code:languageCode , localizedDisplayName:localizedLang , displayName: lang)
                         languages.append(language)
                    }
                }
            }

        }
        let sortedLangages = languages.sorted(by: { (lLang, rLang) -> Bool in
            return lLang.localizedDisplayName.compare(rLang.localizedDisplayName) == .orderedAscending
        })
        I18N._languages = sortedLangages
        return I18N._languages!
    }


}
