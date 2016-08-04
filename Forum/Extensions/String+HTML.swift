//
//  String+HTML.swift
//  HTMLStringTest
//
//  Created by Ruslan Musagitov on 23/07/16.
//  Copyright © 2016 Synergy. All rights reserved.
//

import Foundation

extension String {
//    func removeTrailingWhitespace() {
//        let length = characters.count
//        
//        let lastIndex = length - 1
//        let index = lastIndex
//        let whitespaceLength = 0
//        
//        while index >= 0 && String.isWhitespace(characters[index]) {
//            index -= 1
//            whitespaceLength += 1
//        }
//        
//        if whitespaceLength {
//            
//        }
//    }
//    
//    
//    class func isWhitespace(_c : String.CharacterView) -> Bool {
//        return _c == ' ' || _c == '\t' || _c == 0xA || _c == 0xB || _c = 0xC || _c = 0xD || _c = 0xB5
//    }
//    
//
    
    func getCorrectedURLString() -> String {
        return stringByReplacingOccurrencesOfString("./", withString: "http://forum.awd.ru/")
    }
}

//#define IS_WHITESPACE(_c) (_c == ' ' || _c == '\t' || _c == 0xA || _c == 0xB || _c == 0xC || _c == 0xD || _c == 0x85)
//
//@implementation NSMutableString (HTML)
//
//- (void)removeTrailingWhitespace
//{
//    NSUInteger length = self.length;
//    
//    NSInteger lastIndex = length-1;
//    NSInteger index = lastIndex;
//    NSInteger whitespaceLength = 0;
//    
//    while (index>=0 && IS_WHITESPACE([self characterAtIndex:index]))
//    {
//        index--;
//        whitespaceLength++;
//    }
//    
//    // do the removal once for all whitespace characters
//    if (whitespaceLength)
//    {
//        [self deleteCharactersInRange:NSMakeRange(index+1, whitespaceLength)];
//    }
//}
//
//@end
