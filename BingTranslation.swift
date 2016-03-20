/*  BingTranslation.swift
  The MIT License (MIT)

Copyright (c) 2016 pengqian

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

  Copyright © 2016年 彭芊. All rights reserved.
*/
enum BingLanguage : String{
    case ARABIC = "ar",
    BULGARIAN = "bg",
    CATALAN = "ca",
    CHINESE_SIMPLIFIED = "zh-CHS" ,
    CHINESE_TRADITIONAL = "zh-CHT",
    CZECH = "cs" ,
    DANISH = "da" ,
    DUTCH = "nl" ,
    ENGLISH = "en" ,
    ESTONIAN = "et" ,
    FINNISH = "fi" ,
    FRENCH = "fr" ,
    GERMAN = "de" ,
    GREEK = "el" ,
    HAITIAN_CREOLE="ht" ,
    HEBREW = "he" ,
    HINDI = "hi" ,
    HMONG_DAW = "mww" ,
    HUNGARIAN = "hu" ,
    INDONESIAN = "id" ,
    ITALIAN = "it" ,
    JAPANESE = "ja" ,
    KOREAN = "ko" ,
    LATVIAN = "lv" ,
    LITHUANIAN = "lt" ,
    MALAY = "ms" ,
    NORWEGIAN = "no" ,
    PERSIAN = "fa" ,
    POLISH = "pl" ,
    PORTUGUESE = "pt" ,
    ROMANIAN = "ro" ,
    RUSSIAN = "ru" ,
    SLOVAK = "sk" ,
    SLOVENIAN = "sl" ,
    SPANISH = "es" ,
    SWEDISH = "sv" ,
    THAI = "th" ,
    TURKISH = "tr" ,
    UKRAINIAN = "uk" ,
    URDU = "ur" ,
    VIETNAMESE = "vi"
    
    var name : String{
        return self.rawValue
    }
}

class BingTranslation{
    let client_id = "Your ID" //应用ID
    let client_secret = "Your Secrent" //应用密匙
    
    let baseUrl = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
    
    private var timeLive = NSDate()
    private var token : String = ""
    
    var accessToken : String{
        get{
            let result = NSDate().compare(timeLive)
            switch result{
                case .OrderedSame,.OrderedDescending:
                return getTokens()
                case .OrderedAscending:
                return token
            }
        }
    }
    
    static var instance : BingTranslation! = nil
    
    static func shared() -> BingTranslation{
        if instance == nil{
            instance =  BingTranslation()
        }
        return instance
    }
    
    //通过HTTP POST请求获取token
    func getTokens() -> String{
        var token : String = ""
        let param = "scope=http://api.microsofttranslator.com&grant_type=client_credentials&client_id=\(client_id)&client_secret=\(client_secret)"
        let data = param.dataUsingEncoding(NSUTF8StringEncoding)
        let authorUrl = NSURL(string: baseUrl)
        let request = NSMutableURLRequest(URL: authorUrl!)
        request.HTTPMethod = "POST"
        request.HTTPBody = data
        do{
            var response : NSURLResponse? = nil
            let reData =  try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            if response is NSHTTPURLResponse{
                let httpResponse = response as! NSHTTPURLResponse
                if httpResponse.statusCode != 200{
                    token = ""
                    print("error200 \(httpResponse)")
                }else{
                    let jsonDict = try NSJSONSerialization.JSONObjectWithData(reData, options: NSJSONReadingOptions.MutableContainers)
                    token = jsonDict.valueForKey("access_token") as! String
                    let interval = jsonDict.valueForKey("expires_in") as! String
                    self.timeLive = NSDate(timeInterval: NSTimeInterval(interval)!, sinceDate: NSDate())
                    self.token = token
                }
            }
        }catch let error{
            print("TOKENerror \(error)")
        }
        return token
    }
    
    func translateText(text text : String,from : BingLanguage!,to : BingLanguage!) -> String{
        var result : String = text
        let post = "http://api.microsofttranslator.com/v2/Http.svc/Translate?text=\(text)&from=\(from.name)&to=\(to.name)"
        if let uri = post.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding){
            let url = NSURL(string: uri)
            let request = NSMutableURLRequest(URL: url!)
            let head = "Bearer \(self.accessToken)"
            request.addValue(head, forHTTPHeaderField: "Authorization")
            do{
                var response : NSURLResponse? = nil
                let reData =  try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
                if response is NSHTTPURLResponse{
                    let httpResponse = response as! NSHTTPURLResponse
                    if httpResponse.statusCode != 200{
                        print("error200 \(httpResponse)")
                    }else{
                        var trans =  NSString(data: reData, encoding: NSUTF8StringEncoding)!
                        let regex = try NSRegularExpression(pattern: "</?(S|s)tring.*?>", options: NSRegularExpressionOptions.DotMatchesLineSeparators)
                        let results = regex.matchesInString(trans as String, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, trans.length))
                        if results.count % 2 == 0{
                            let start = results[0].range.length
                            let end = results[1].range.location
                            trans = trans.substringWithRange(NSMakeRange(start,end - start))
                            result = trans as String
                        }
                    }
                }
            }catch let error{
                print("TRANSerror \(error)")
            }
        }else{
           print("UTF8 error")
        }
        return result
    }
    
    func languageDetect(text : String) -> BingLanguage{
        var result : BingLanguage = BingLanguage.ENGLISH
        let post = "http://api.microsofttranslator.com/V2/Ajax.svc/Detect?text=\(text)"
        if let uri = post.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding){
            let url = NSURL(string: uri)
            let request = NSMutableURLRequest(URL: url!)
            let head = "Bearer \(self.accessToken)"
            request.addValue(head, forHTTPHeaderField: "Authorization")
            do{
                var response : NSURLResponse? = nil
                let reData =  try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
                if response is NSHTTPURLResponse{
                    let httpResponse = response as! NSHTTPURLResponse
                    if httpResponse.statusCode != 200{
                        print("error200 \(httpResponse)")
                    }else{
                        let trans =  NSString(data: reData, encoding: NSUTF8StringEncoding)!
                        if let lan = BingLanguage(rawValue: trans as String){
                            result = lan
                        }
                    }
                }
            }catch let error{
                print("DETECTerror \(error)")
            }
        }
        return result
    }
    
    func translateText(text text : String,to : BingLanguage!) -> String{
        let from = languageDetect(text)
        return translateText(text: text, from: from, to: to)
    }
    
    func translateText(text text : String,from : String,to : String) -> String{
        let _from = BingLanguage(rawValue: from)!
        let _to = BingLanguage(rawValue: to)!
        return translateText(text: text, from: _from, to: _to)
    }
}
