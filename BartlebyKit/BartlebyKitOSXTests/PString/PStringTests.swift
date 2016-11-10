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

    let helloWorld="Hello World"
    let hello="Hello 🗽 liberty"


    /*

     PString.ltrim("    *   Hello    *    ")
     PString.rtrim("    *   Hello    *    ")

     PString.ltrim("*,    *   Hello    *    ",characterSet: CharacterSet(charactersIn:",* "))
     PString.ltrim(",A,B,C",characterSet: CharacterSet(charactersIn:","))
     
     */

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
        XCTAssert(s=="ello Wor") /// ello Worl 
    }

    func test010_substring_PHP_Compliance_negative_values() {
        let s=PString.substr(helloWorld, -9, -3)
         XCTAssert(s=="llo Wo") /// llo Worl
    }

    // Not supported by PHP
    func test0011_substring_unicode_emoticon() {
        XCTAssert(PString.substr(hello, 6, 5)=="🗽 lib")
    }




}