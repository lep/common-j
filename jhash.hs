
import Jass.Ast
import Jass.Parser
import Data.Hashable

import System.Environment

import Control.Monad
import Control.Applicative
import Text.Megaparsec
import Text.Megaparsec.Error

main = do
    args <- getArgs
    forM_ args $ \arg -> do
        x <- runParser programm arg . (++"\n") <$> readFile arg
        case x of
            Right ast -> putStrLn $ unwords [ arg, show $ hash ast ]
            Left err -> putStrLn $ unwords [ arg, "error", errorBundlePretty err ]
    
