//
//  main.swift
//  Fraction-Calc
//
//  Created by Heurihermilab on 04/30/19.
//  Copyright © 2019 Heurihermilab. All rights reserved.
//

// Parses command line input for fractions and operation, calculates and returns result
// USE: $ swift fraction-calc.swift <fraction> <operation> <fraction>
// <fraction> is in form x_n/d, where x is the whole number part and n/d is the fractional part
// <operation> is +, -, *, or /

import Foundation

//MARK:- Fraction

struct Fraction {
	var whole: Int
	var numer: Int
	var denom: Int {
		willSet(newValue) {
			guard newValue != 0 else {
				print("Fraction -- attempted to set denominator to zero")
				exit(EXIT_FAILURE)
			}
		}
	}
	
	init(whole: Int, numer: Int, denom: Int) {
		guard denom != 0 else {
			print("Fraction -- attempted to set denominator to zero")
			exit(EXIT_FAILURE)
		}
		self.whole = whole
		self.numer = numer
		self.denom = denom
	}
	
	static func fromString(_ inputString: String) -> Fraction? {
		//		print(#function, "inputString: \(inputString)")
		var whole = 0
		let underIndex = inputString.firstIndex(of: "_")		// we take this as indicator for presence of whole part and fraction
		let slashIndex = inputString.firstIndex(of: "/")		// we take this as indicator for presence of fraction part
		let pieces = inputString.split(separator: "_")
		guard pieces.count > 0 else { return nil }
		if (underIndex != nil) {
			// break up into whole and fractional parts
			guard let wholePart = Int(pieces[0]) else { return nil }
			whole = wholePart 
			if (slashIndex != nil) {
				// analyze remainder as fraction
				if var subfraction = fractionFromSubstring(pieces[1].split(separator: "/")) {
					if subfraction.numer < 0 && whole != 0 {
						whole = -abs(whole)
						subfraction.numer = abs(subfraction.numer)
					}
					let newFraction = Fraction(whole: whole, numer: subfraction.numer, denom: subfraction.denom)
					return newFraction
				}
			}
		} else if (slashIndex != nil) {
			// no whole part, analyze as fraction
			if let subfraction = fractionFromSubstring(pieces[0].split(separator: "/")) {
				let newFraction = Fraction(whole: 0, numer: subfraction.numer, denom: subfraction.denom)
				return newFraction
			}
		}
		// if there's only one part, try making it an int
		if let wholePart = Int(inputString) { 
			whole = wholePart 
			return Fraction(whole: whole, numer: 0, denom: 1)
		}
		
		return nil
	}
	
	static func fractionFromSubstring(_ inputSubstrings: [Substring]) -> Fraction? {
		guard inputSubstrings.count == 2,
			var numerPart = Int(inputSubstrings[0]),
			var denomPart = Int(inputSubstrings[1]) else { 
				return nil
		}
		if denomPart < 0 {
			// if denominator is negative, normalize by inverting sign of numerator
			// [if both are negative, result is positive, otherwise numerator is negative]
			denomPart = abs(denomPart)
			numerPart = -numerPart
		}
		return Fraction(whole: 0, numer: numerPart, denom: denomPart)
	}
}

extension Fraction {
	typealias Fractions = (Fraction, Fraction)		// ad hoc type for ease of use
	
	func withCommonDenom(_ other: Fraction) -> Fractions {
		// finds common denom for pair of fractions and returns them in entirely fractional format (no whole part)
		let commonDenom = self.denom * other.denom
		// do math in absolute values and make negative if numerator or whole part are negative
		var leftNumer = abs(self.numer * other.denom) + abs(self.whole * commonDenom)
		if self.numer < 0 || self.whole < 0 { leftNumer = -leftNumer }
		var rightNumer = abs(other.numer * self.denom) + abs(other.whole * commonDenom)
		if other.numer < 0 || other.whole < 0 { rightNumer = -rightNumer }
		
		let leftFrac = Fraction(whole: 0, numer: leftNumer, denom: commonDenom)
		let rightFrac = Fraction(whole: 0, numer: rightNumer, denom: commonDenom)
		let fractions = Fractions(leftFrac, rightFrac)
		return fractions
	}
	
	var reducedFraction: Fraction {
		// given a fraction, reduce fraction to lowest common factors and separate whole part
		//		print(#function, "self = \(self)")
		var wholePart = 0
		var remainder = self.numer
		var newDenom = self.denom
		// reduce factors, if possible
		if abs(remainder) > 1 {
			let gcd = abs(Int.gcd(a: remainder, b: self.denom))
			if gcd > 1 {
				remainder = remainder / gcd
				newDenom = newDenom / gcd
			}
		}
		// separate whole amount if any
		if abs(remainder) > newDenom {
			wholePart = remainder / newDenom
			remainder = remainder % newDenom
			if remainder < 0 {
				// if remainder is negative, propagate it to the whole part (if there is one)
				wholePart = -abs(wholePart)
				remainder = abs(remainder)
			}
		}
		let newFrac = Fraction(whole: wholePart, numer: remainder, denom: newDenom)
		return newFrac
	}
	
	static func + (left: Fraction, right: Fraction) -> Fraction {
		let fractions = left.withCommonDenom(right)
		let newNumer = fractions.0.numer + fractions.1.numer
		let newFrac = Fraction(whole: 0, numer: newNumer, denom: fractions.0.denom).reducedFraction
		return newFrac
	}
	
	static func - (left: Fraction, right: Fraction) -> Fraction {
		let fractions = left.withCommonDenom(right)
		let newNumer = fractions.0.numer - fractions.1.numer
		let newFrac = Fraction(whole: 0, numer: newNumer, denom: fractions.0.denom).reducedFraction
		return newFrac
	}
	
	static func * (left: Fraction, right: Fraction) -> Fraction {
		let fractions = left.withCommonDenom(right)
		let newNumer = fractions.0.numer * fractions.1.numer
		let newDenom = fractions.0.denom * fractions.1.denom
		let newFrac = Fraction(whole: 0, numer: newNumer, denom: newDenom).reducedFraction
		return newFrac
	}
	
	static func / (left: Fraction, right: Fraction) -> Fraction {
		let fractions = left.withCommonDenom(right)
		// division of A by B is the equivalent of multiplication by the reciprocal of B
		let newNumer = fractions.0.numer * fractions.1.denom
		let newDenom = fractions.0.denom * fractions.1.numer
		let newFrac = Fraction(whole: 0, numer: newNumer, denom: newDenom).reducedFraction
		return newFrac
	}
	
}

extension Int {
	// returns greatest common denominator for pair of integers (recursive)
	static func gcd(a: Int, b: Int) -> Int {
		let theGCD = b != 0 ? gcd(a: b, b: a % b) : a
		return theGCD
	}
}

//MARK:- execution begins here

// get strings from command line input
var strings = [String]()
for item in CommandLine.arguments {
	strings.append(item)
}

// check for expected number of arguments -- 2 or 4
if strings.count == 2 {
	// 2 strings could mean we were given fractions and operand as a quoted string
	// [without quoting the * cannot be used, so we silently fix it]
	let splitString = strings[1].split(separator: " ")
	if splitString.count == 3 {
		// rebuild strings array
		let tempStr = strings[0]
		strings = [tempStr]
		for item in splitString {
			strings.append(String(item))
		}
	}
}

// at this point there should be 4 arguments
guard strings.count == 4 else {  
	print("Malformed input string")
	exit(EXIT_FAILURE)
}

// this does the calculation from the input strings
func calculate(_ strings: [String]) -> String {
	guard let biff = Fraction.fromString(strings[1]),
		let pop = Fraction.fromString(strings[3]) else {
			print("Could not parse fractional inputs")
			exit(EXIT_FAILURE)
	}
	
	var opResult = Fraction(whole: 0, numer: 0, denom: 1)
	switch strings[2] {
	case "+": opResult = biff + pop
	case "-": opResult = biff - pop
	case "*": opResult = biff * pop
	case "/": opResult = biff / pop
	default: 
		print("Unrecognized operation")
		exit(EXIT_FAILURE)
	}
	
	// if the numerator is 0, just print the whole part
	var resultStr = ""
	if opResult.numer == 0 {
		resultStr = "= \(opResult.whole)"
	} else {
		resultStr = "= \(opResult.whole)_\(opResult.numer)/\(opResult.denom)"
	}
	return resultStr
}

let result = calculate(strings)
print(result)
exit(EXIT_SUCCESS)
