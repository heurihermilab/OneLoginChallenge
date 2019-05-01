//
//  FC_test.swift
//  FC-test
//
//  Created by Heurihermilab on 04/30/19.
//  Copyright © 2019 Heurihermilab. All rights reserved.
//

import XCTest

class FC_test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
	}

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	let testData = [ "= 14": [ "dummy", "2", "*", "7"],
					 "= 0_2/7": [ "dummy", "2", "/", "7"],
					 "= -5": [ "dummy", "2", "-", "7"],
					 "= 16_129/280": [ "dummy", "2_1/5", "*", "7_27/56"],
					 "= 0_616/2095": [ "dummy", "2_1/5", "/", "7_27/56"],
					 "= 9_191/280": [ "dummy", "2_1/5", "+", "7_27/56"],
					 "= -5_79/280": [ "dummy", "2_1/5", "-", "7_27/56"],
					 "= -15_30/31": [ "dummy", "4_-5/7", "*", "3_12/31"],
					 "= -1_96/245": [ "dummy", "4_-5/7", "/", "3_12/31"],
					 "= -1_71/217": [ "dummy", "4_-5/7", "+", "3_12/31"],
					 "= -8_22/217": [ "dummy", "4_-5/7", "-", "3_12/31"]
	]

    func testStrings() {
		for key in testData.keys {
			let fracResult = calculate(testData[key]!)
			XCTAssertEqual(fracResult, key, "\(testData[key]![1]) \(testData[key]![2]) \(testData[key]![3]) != \(fracResult), should be \(key)")
		}
		
	}


}
