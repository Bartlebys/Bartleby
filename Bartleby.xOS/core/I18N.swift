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
    public let code:String
    public let localizedDisplayName:String
    public let displayName:String
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
            return lLang.code.compare(rLang.code) == .orderedAscending
        })
        I18N._languages = sortedLangages
        return I18N._languages!
    }


    static public func dump( counterSeparator: String = ".", separator: String = "|"){
        var counter = 0
        for language in I18N.languages{
            counter += 1
            Swift.print("\(counter)\(counterSeparator) \(language.code)\(separator)\(language.displayName)\(separator)\(language.localizedDisplayName)")
        }
    }

}


open class Localized{

    // The associated reference
    fileprivate var _reference:ManagedModel!

    init( reference:ManagedModel){
        self._reference = reference
    }


    // MARK: - General

    /// Return all the languages code available for a given key
    ///
    /// - Parameter key: the cibled key
    /// - Returns: the language codes
    open func getLanguageCodesForkey(key:String)->[String]{
        let localizedDatas:[LocalizedDatum] = self._reference.relations(Relationship.owns)
        let filtered = localizedDatas.filter { (datum) -> Bool in
            return datum.key == key
        }
        var languageCodes:[String] = filtered.map { (datum) -> String in
            return datum.languageCode
        }
        if self._reference.exposedKeys.contains(key){
            languageCodes.append(self._reference.languageCode)
        }
        return languageCodes
    }

    // MARK: - String API


    /// Sets the string value for a given key for the designated LanguageCode
    /// If the value equals the base value we do not create a localized data
    ///
    /// - Parameters:
    ///   - key: the key
    ///   - stringValue: the value
    ///   - languageCode: the language code to use (if set to the model language code it will try to set the native property)
    open func setString( key:String,stringValue:String,languageCode:String)->(){

        if let baseValue = try? self._reference.getExposedValueForKey(key) as? String{
            if baseValue == stringValue {
                return
            }
        }

        // #1 Is it the base value?
        // Let use the Exposed API to try to set the original value
        do{
            if languageCode == _reference.languageCode{
                try self._reference.setExposedValue(stringValue,forKey:key)
                return
            }
        }catch{}

        // #2 Do we already have this localized Datum ?
        let localizedDatas:[LocalizedDatum] = self._reference.relations(Relationship.owns)
        if let localizedDatum:LocalizedDatum = localizedDatas.first(where: { (datum) -> Bool in
            return datum.key == key && datum.languageCode == languageCode
        }){
            localizedDatum.stringValue = stringValue
            return
        }

        // #3 Create a new LocalizedDatum
        if let localizedDatum:LocalizedDatum = self._reference.referentDocument?.newManagedModel(){
            localizedDatum.key = key
            localizedDatum.stringValue = stringValue
            localizedDatum.languageCode = languageCode
            self._reference.declaresOwnership(of: localizedDatum)
        }
    }


    /// Returns the string value for a given language code.
    ///
    /// - Parameters:
    ///   - key: the key
    ///   - languageCode: the language code
    /// - Returns: the value
    open func getString( key:String,languageCode:String)->String?{
        if self._reference.languageCode == languageCode{
            do { return try self._reference.getExposedValueForKey(key) as? String } catch {}
        }
        let localizedDatas:[LocalizedDatum] = self._reference.relations(Relationship.owns)
        if let localizedDatum:LocalizedDatum = localizedDatas.first(where: { (datum) -> Bool in
            return datum.key == key && datum.languageCode == languageCode
        }){
            return localizedDatum.stringValue
        }
        return nil
    }



    /// Returns the string value for a given language code or the base native value
    ///
    /// - Parameters:
    ///   - key: the key
    ///   - languageCode: the language code
    /// - Returns: the string
    open func getStringOrBaseValue( key:String,languageCode:String)->String?{
        if let string = self.getString(key: key, languageCode: languageCode){
            return string
        }
        return (try? self._reference.getExposedValueForKey(key)) as? String
    }





    /// Returns all the available strings
    ///
    /// - Parameter key: the key
    /// - Returns: the strings
    open func getStringList( key:String)->[String]{
        let localizedDatas:[LocalizedDatum] = self._reference.relations(Relationship.owns)
        let filtered = localizedDatas.filter { (datum) -> Bool in
            return datum.stringValue != nil
        }
        return filtered.map({ (datum) -> String in
            return datum.stringValue!
        })
    }



    // MARK: - Data




    /// Sets the data value for a given key for the designated LanguageCode
    /// If the value equals the base value we do not create a localized data
    ///
    /// - Parameters:
    ///   - key: the key
    ///   - dataValue: the value
    ///   - languageCode: the language code to use (if set to the model language code it will try to set the native property)
    open func setData( key:String,dataValue:Data,languageCode:String){

        if let baseValue = try? self._reference.getExposedValueForKey(key) as? Data{
            if baseValue == dataValue {
                return
            }
        }

        // #1 Is it the base value?
        // Let use the Exposed API to try to set the original value
        do{
            if languageCode == _reference.languageCode{
                try self._reference.setExposedValue(dataValue,forKey:key)
                return
            }
        }catch{}

        // #2 Do we already have this localized Datum ?
        let localizedDatas:[LocalizedDatum] = self._reference.relations(Relationship.owns)
        if let localizedDatum:LocalizedDatum = localizedDatas.first(where: { (datum) -> Bool in
            return datum.key == key && datum.languageCode == languageCode
        }){
            localizedDatum.dataValue = dataValue
            return
        }

        // #3 Create a new LocalizedDatum
        if let localizedDatum:LocalizedDatum = self._reference.referentDocument?.newManagedModel(){
            localizedDatum.key = key
            localizedDatum.dataValue = dataValue
            localizedDatum.languageCode = languageCode
            self._reference.declaresOwnership(of: localizedDatum)
        }
    }


    /// Returns the data value for a given language code.
    ///
    /// - Parameters:
    ///   - key: the key
    ///   - languageCode: the language code
    /// - Returns: the value
    open func getData( key:String,languageCode:String)->Data?{
        if self._reference.languageCode == languageCode{
            do { return try self._reference.getExposedValueForKey(key) as? Data } catch {}
        }
        let localizedDatas:[LocalizedDatum] = self._reference.relations(Relationship.owns)
        if let localizedDatum:LocalizedDatum = localizedDatas.first(where: { (datum) -> Bool in
            return datum.key == key && datum.languageCode == languageCode
        }){
            return localizedDatum.dataValue
        }
        return nil
    }


    /// Returns the data value for a given language code or the base native value
    ///
    /// - Parameters:
    ///   - key: the key
    ///   - languageCode: the language code
    /// - Returns: the string
    open func getDataOrBaseValue( key:String,languageCode:String)->Data?{
        if let  data = self.getData(key: key, languageCode: languageCode){
            return data
        }
        return (try? self._reference.getExposedValueForKey(key)) as? Data
    }



    /// Returns all the available data for a given key
    ///
    /// - Parameter key:
    /// - Returns:
    open func getDataList( key:String)->[Data]{
        let localizedDatas:[LocalizedDatum] = self._reference.relations(Relationship.owns)
        let filtered = localizedDatas.filter { (datum) -> Bool in
            return datum.dataValue != nil
        }
        return filtered.map({ (datum) -> Data in
            return datum.dataValue!
        })
    }


    // MARK: - Deletion


    /// Deletes the associated LocalizedDatum if there is one
    ///
    /// - Parameters:
    ///   - key: for a given key
    ///   - languageCode: and a given language code
    open func deleteKey(key:String,languageCode:String)throws->(){
        let localizedDatas:[LocalizedDatum] = self._reference.relations(Relationship.owns)
        if let localizedDatum:LocalizedDatum = localizedDatas.first(where: { (datum) -> Bool in
            return datum.key == key && datum.languageCode == languageCode
        }){
            try localizedDatum.erase()
        }
    }

}
