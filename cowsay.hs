import Data.List (isPrefixOf, elemIndex, isSuffixOf, sort)
import System.Console.GetOpt
import System.Directory (getDirectoryContents)
import System.Environment (getArgs, getProgName)

data Options = Options
      { optThoughts :: String
      , optEyes     :: String
      , optTongue   :: String
      , optFile     :: String
      , optWidth    :: Int
      , optIsList   :: Bool }
    deriving Show

defaultOptions   :: Options
defaultOptions    = Options
    { optThoughts = "\\"
    , optEyes     = "oo"
    , optTongue   = "  "
    , optFile     = "default"
    , optWidth    = 40
    , optIsList   = False }

options :: [OptDescr (Options -> Options)]
options = [
  Option "l" ["list"]     (NoArg setListFils)         "List available cows",
  Option "f" ["file"]     (ReqArg setFile "FILE")     "Set cow type",
  Option "W" ["width"]    (ReqArg setWidth "WIDTH")   "Set max message width",
  Option "b" ["borg"]     (NoArg $ setEyes "==")      "Borg cow mode",
  Option "d" ["dead"]     (NoArg $ setFace "xx" "U")  "Dead cow mode",
  Option "g" ["greedy"]   (NoArg $ setEyes "$$")      "Greedy cow mode",
  Option "p" ["paranoid"] (NoArg $ setEyes "@@")      "Paranoid cow mode",
  Option "s" ["stoned"]   (NoArg $ setFace "**" "U" ) "Stoned cow mode",
  Option "t" ["tired"]    (NoArg $ setEyes "**")      "Tired cow mode",
  Option "w" ["wired"]    (NoArg $ setEyes "OO")      "Wired cow mode",
  Option "y" ["young"]    (NoArg $ setEyes "..")      "Young cow mode",
  Option "e" ["eyes"]     (ReqArg setEyes "EYES")     "Set cow eyes",
  Option "T" ["tongue"]   (ReqArg setTongue "TONGUE") "Set cow tongue"
  ]
  where setEyes e o   = o { optEyes = take 2 (rightPadStr ' ' 2 e) }
        setTongue t o = o { optTongue = take 2 (rightPadStr ' ' 2 t) }
        setFace e t   = setTongue t . setEyes e
        setFile f o   = o { optFile = f }
        setWidth w o  = o { optWidth = read w }
        setListFils o = o { optIsList = True }

getOptions :: [Options -> Options] -> Options
getOptions = foldl (flip id) defaultOptions

main :: IO ()
main = do
    args <- getArgs
    progName <- getProgName
    case getOpt Permute options args of
      (o, n, []) -> runProgram (getOptions o) (unlines n)
      _          -> putStrLn $ usageInfo (usageStr progName) options
  where usageStr progName = "Usage: " ++ progName ++ " [OPTIONS] [MESSAGE]"

runProgram :: Options -> String -> IO ()
runProgram o msg | optIsList o = listCowFiles
                 | otherwise   = printCow o msg

listCowFiles :: IO ()
listCowFiles = do
    files <- getDirectoryContents "cows"
    putStrLn "Available cow files:"
    mapM_ putStrLn $ cowFiles files
  where cowFiles fs = [ "- " ++ take (length f - 4) f | f <- sortedFiles fs]
        sortedFiles fs = sort  $ filter (isSuffixOf ".cow") fs


printCow :: Options -> String -> IO ()
printCow o msg = do
    cow <- readFile $ "cows/" ++ optFile o ++ ".cow"
    mapM_ putStrLn $ buildBalloon o msg'
    mapM_ putStrLn $ convertFile o $ lines cow
  where msg' | null msg  = "Mooooooooooooo! Don't forget to specify a message! "
                        ++ "Use the -h flag for help!"
             | otherwise = msg

buildBalloon :: Options -> String -> [String]
buildBalloon o msg = [row '_'] ++ (content ls) ++ [row '-']
  where row c     = " " ++ replicate (rowLength + 2) c ++ " "
        rowLength = maximum $ map length ls
        ls        = lines $ wrapLine msg (optWidth o)

        content (l:[]) = ["< " ++ l ++ " >"]
        content ls'    = zipWith3 merge firstCols ls' lastCols

        merge l m r = l ++ rightPadStr ' ' rowLength m ++ r
        firstCols   = (cols "/ " "| " "\\ ")
        lastCols    = (cols " \\" " |" " /")
        cols l m r  = [l] ++ replicate (length ls - 2) m ++ [r]


convertFile :: Options -> [String] -> [String]
convertFile o ls = map (replaceVars o) $ filter validLine $ init ls
  where validLine (c:_) = c `notElem` "#$"
        validLine  _    = True

replaceVars :: Options -> String -> String
replaceVars o l = case elemIndex '$' l of
    Nothing -> l
    Just i  -> replaceVars o $ foldr (\s ln -> replaceVar ln i s) l subs
  where subs = [ ("thoughts", optThoughts o)
               , ("eyes",     optEyes o)
               , ("tongue",   optTongue o) ]

replaceVar :: String -> Int -> (String, String) -> String
replaceVar l i (k, v)
    | k `isPrefixOf` post  = init pre ++ v ++ drop (length k) post
    | otherwise            = l
  where (pre, post) = splitAt (i+1) l


wrapLine :: String -> Int -> String
wrapLine cs = wrapLine' (words cs) 0

wrapLine' :: [String] -> Int -> Int -> String
wrapLine' []     _ _ = ""
wrapLine' (w:ws) i i'max = spacer ++ nextWord
  where spacer = [c | i > 0]
        nextWord = w ++ wrapLine' ws i'new i'max
        fits = i + length w < i'max
        i'new | fits      = i + length w
              | otherwise = length w
        c     | fits      = ' '
              | otherwise = '\n'

rightPadStr :: Char -> Int -> String -> String
rightPadStr c i s = s ++ replicate (i - length s) c
