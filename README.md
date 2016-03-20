# BingTranslation.Swift
A simple way to use Bing Translation in swift

#How to use
1.Go to [Microsoft](https://www.microsoft.com/en-us/translator/getstarted.aspx) and get the client_id and client_secret <br>
2.Change the parameters client_id and client_secret

#Functions
1.func translateText(text text : String,from : BingLanguage!,to : BingLanguage!) -> String <br>
2.func languageDetect(text : String) -> BingLanguage <br>
3.func translateText(text text : String,to : BingLanguage!) -> String <br>
4.func translateText(text text : String,from : String,to : String) -> String <br>
