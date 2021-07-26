module Main where

import "async" Control.Concurrent.Async (async)
import "base" Control.Monad.IO.Class (liftIO)
import "base" Data.Functor (void)
import "lens" Control.Lens ((^.))
import "joint" Control.Joint (adapt)
import "optparse-applicative" Options.Applicative (Parser, execParser, argument, auto, info, fullDesc, metavar, str)
import "servant-server" Servant (Capture, ReqBody, Server, JSON, Post, Proxy (Proxy), type (:>), serve, err403, throwError)
import "telega" Network.API.Telegram.Bot (Telegram, Token (Token), telegram)
import "telega" Network.API.Telegram.Bot.Field.Title (Title (Title))
import "telega" Network.API.Telegram.Bot.Object (Callback (Datatext), Origin (Group), Content (Command))
import "telega" Network.API.Telegram.Bot.Object.Chat (Chat, ID (CHAT))
import "telega" Network.API.Telegram.Bot.Object.Update (Update (Incoming))
import "telega" Network.API.Telegram.Bot.Object.Update.Message (Message (Direct), Send (Send), Poll (Poll), Option (Option))
import "telega" Network.API.Telegram.Bot.Property (access, persist, ID)
import "text" Data.Text (pack)
import "warp" Network.Wai.Handler.Warp (run)
import "wai-extra" Network.Wai.Middleware.RequestLogger (logStdoutDev)

data Arguments = Arguments Token (ID Chat) Int

options :: Parser Arguments
options = Arguments <$> token <*> chat_id <*> election_duration where

	token :: Parser Token
	token = Token . pack <$> argument str (metavar "TELEGRAM_TOKEN")

	chat_id :: Parser (ID Chat)
	chat_id = CHAT . negate <$> argument auto (metavar "CHAT_ID")

	election_duration :: Parser Int
	election_duration = argument auto (metavar "ELECTION_DURATION")

type API = "webhook" :> ReqBody '[JSON] Update :> Post '[JSON] ()

server :: Arguments -> Server API
server (Arguments token chat_id election_duration) update = do
	let action =  telegram token () $ webhook update
	liftIO . void . async $ action >>= print

webhook :: Update -> Telegram () ()
webhook (Incoming _ (Direct msg_id (Group chat_id _ sender) (Command cmd))) = case cmd of
	"initiate@terminus_plebiscite_bot" -> do
		msg <- persist . Send chat_id 
			$ Poll "Who do you prefer?" [Option (Title "Murat Kasimov") 0, Option (Title "Vladislav Khikhlov") 0]
		adapt $ print msg
webhook x = adapt (print x)

main = execParser (info options fullDesc) >>= run 8080 . logStdoutDev . serve (Proxy :: Proxy API) . server
