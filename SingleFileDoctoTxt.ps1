Const wdFormatText = 2

Set objWord = CreateObject(“Word.Application”)

objWord.Visible = TRUE

Set objDoc = objWord.Documents.Open(“C:\myfile.doc”)

objDoc.SaveAs “C:\myfile.txt”, wdFormatText


objWord.Quit
