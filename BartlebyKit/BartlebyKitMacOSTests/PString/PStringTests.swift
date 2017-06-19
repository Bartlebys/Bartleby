//
//  PStringTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 09/11/2016.
//
//

import XCTest
import BartlebyKit


class PStringTests: XCTestCase {

    // MARK: - substring

    /*

     The Next results are compared to :

     <?php

     echo substr("Hello World",0,11)."\n";//    Hello World
     echo substr("Hello World",0)."\n";//       Hello World

     echo substr("Hello World",0,5)."\n";//     Hello
     echo substr("Hello World",6,6)."\n";//     World

     echo substr("Hello World",0,10)."\n";//    Hello Worl
     echo substr("Hello World",1,8)."\n";//     ello Wor


     echo substr("Hello World",0,-1)."\n";//    Hello Worl
     echo substr("Hello World",0,-6)."\n";//    Hello

     echo substr("Hello World",-1,5)."\n";//    d
     echo substr("Hello World",-2,2)."\n";//    ld

     echo substr("Hello World",-10,-2)."\n";//  ello Wor

     echo substr("Hello World",-9,-3)."\n";//   llo Wo

     echo substr("Hello 🗽 liberty",6,5)."\n";// 🗽
     
     ?>
     
     */


    let helloWorld="Hello World"
    let hello="Hello 🗽 liberty"

    func test001_substring_PHP_Compliance() {
        XCTAssert(PString.substr(helloWorld, 0, 2)=="He")
    }

    func test002_substring_PHP_Compliance() {
        XCTAssert(PString.substr(helloWorld, 1, 1)=="e")
        XCTAssert(PString.substr(helloWorld, 0, 0)=="")
    }

    func test003_substring_PHP_Compliance() {
        XCTAssert(PString.substr(helloWorld, 3, 2)=="lo")
    }



    func test005_substring_PHP_Compliance() {
        XCTAssert(PString.substr(helloWorld, 0, 11)==helloWorld)
        XCTAssert(PString.substr(helloWorld, 0)==helloWorld)
    }

    func test004_substring_PHP_Compliance() {
        XCTAssert(PString.substr(helloWorld, 0, 5)=="Hello")
        XCTAssert(PString.substr(helloWorld, 6, 6)=="World") // excess
    }


    func test006_substring_PHP_Compliance() {
        XCTAssert(PString.substr(helloWorld, 0, 10)=="Hello Worl")
        XCTAssert(PString.substr(helloWorld, 1, 8)=="ello Wor")
    }

    func test007_substring_PHP_Compliance_negative_values() {
        XCTAssert(PString.substr(helloWorld, 0, -1)=="Hello Worl")
        XCTAssert(PString.substr(helloWorld, 0, -6)=="Hello")
    }

    func test008_substring_PHP_Compliance_negative_values() {
        XCTAssert(PString.substr(helloWorld, -1,5)=="d")
        XCTAssert(PString.substr(helloWorld, -2,2)=="ld")
    }

    func test009_substring_PHP_Compliance_negative_values() {
        let s=PString.substr(helloWorld, -10, -2)
        XCTAssert(s=="ello Wor")
    }

    func test010_substring_PHP_Compliance_negative_values() {
        let s=PString.substr(helloWorld, -9, -3)
         XCTAssert(s=="llo Wo")
    }

    // MARK: -

    // Not supported by PHP
    func test0011_substring_unicode_emoticon() {
        XCTAssert(PString.substr(hello, 6, 5)=="🗽 lib")
    }


    // MARK: - Trimming

    func test0012_ltrim() {
        let s=PString.ltrim("    *   Hello    *    ")
        XCTAssert(s=="*   Hello    *    ")
    }

    func test0013_rtrim() {
        let s=PString.rtrim("    *   Hello    *    ")
        XCTAssert(s=="    *   Hello    *")
    }

    func test0013_ltrim_charset() {
        let s=PString.ltrim("*,    *   Hello    *    ",characterSet: CharacterSet(charactersIn:",* "))
        XCTAssert(s=="Hello    *    ")
    }

    func test0014_ltrim_charset() {
        let s=PString.ltrim(",A,B,C",characterSet: CharacterSet(charactersIn:","))
        XCTAssert(s=="A,B,C")
    }


    // MARK: - substr_replace

    /*

     <?php
     echo substr_replace("Hello World","Bob",6);//    Hello Bob
     echo ("\n");
     echo substr_replace("Hello World","Bob",20);//    Hello WorldBob
     echo ("\n");
     echo substr_replace("Hello World","Bob",6,3);//    Hello Bobld
     echo ("\n");
     echo substr_replace("Hello World","Hummingbird",6,2);//    Hello Hummingbirdrld
     echo ("\n");
     echo substr_replace("Hello World","Dolly",6,0);//    Hello DollyWorld
     echo ("\n");
     echo substr_replace("Hello World","Dolly",6,-1);//    Hello Dollyd
     echo ("\n");
     echo substr_replace("Hello World","Dolly",6,-3);//    Hello Dollyrld
     echo ("\n");
     ?>

     */
    func test16_substr_replace(){
        let s=PString.substr_replace(helloWorld, replacement: "Bob", start: 6)
        XCTAssert(s=="Hello Bob","\(s)")
    }

    func test17_substr_replace(){
        let s=PString.substr_replace(helloWorld, replacement: "Bob", start: 20)
        XCTAssert(s=="Hello WorldBob","\(s)")
    }

    func test18_substr_replace(){
        let s=PString.substr_replace(helloWorld, replacement: "Bob", start: 6,length:3)
        XCTAssert(s=="Hello Bobld","\(s)")
    }

    func test19_substr_replace(){
        let s=PString.substr_replace(helloWorld, replacement: "Hummingbird", start: 6,length:2)
        XCTAssert(s=="Hello Hummingbirdrld","\(s)")
    }

    func test20_substr_replace(){
        let s=PString.substr_replace(helloWorld, replacement: "Dolly", start: 6,length:0)
        XCTAssert(s=="Hello DollyWorld","\(s)")
    }

    func test21_substr_replace(){
        let s=PString.substr_replace(helloWorld, replacement: "Dolly", start: 6,length:-1)
        XCTAssert(s=="Hello Dollyd","\(s)")
    }

    func test22_substr_replace(){
        let s=PString.substr_replace(helloWorld, replacement: "Dolly", start: 6,length:-3)
        XCTAssert(s=="Hello Dollyrld","\(s)")
    }

}
