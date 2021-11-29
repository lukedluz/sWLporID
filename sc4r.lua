function DBWl(res)
    if res == getThisResource() then
        db = dbConnect("sqlite","whitelist.sqlite")
        dbExec(db,"CREATE TABLE IF NOT EXISTS Whitelist (Serial,ID,StatusWL)")
    end
    if db then
        outputDebugString("CONEXÃO WL CONCLUIDA")
    else
        outputDebugString("CONEXÃO WL FALHOU")
    end
end
addEventHandler("onResourceStart",resourceRoot,DBWl)

function getPlayerID(id)
    if id then
        v = false
        for i, player in ipairs(getElementsByType("player")) do
            if getElementData(player,ElementDataID) == id then
                v = player
                break
            end
        end
    end
    return v
end

function getFreeID()
    ID = false
    local result = dbPoll(dbQuery(db, "SELECT * FROM Whitelist"),-1)
    if #result ~= 0 then
        local NovoID = (#result +1)
        ID = NovoID
    else
        ID = 1
    end
    return ID
end

function AtualizarWL(serial)
    local result = dbPoll(dbQuery(db, "SELECT * FROM Whitelist WHERE Serial = ?", serial),-1)
    local novoid = getFreeID()
    if #result ~= 0 then
    else
        dbExec(db, "INSERT INTO Whitelist VALUES(?,?,?)",serial,novoid,0)
        outputConsole("atualizado")
    end
end

function Connect(_,_,_,serial)
    AtualizarWL(serial)
    local result = dbPoll(dbQuery(db, "SELECT * FROM Whitelist WHERE Serial = ?", serial), -1)
    if #result ~= 0 then
        local WL = result[1]["StatusWL"]
        local MeuID = result[1]["ID"]
        if WL == 0 then
            Mensagem = "Você não tem whiteList [ID : "..MeuID.."]\nEntre [SEU DISCORD] para realizar sua whitelist\nLeia as regras do servidor para a Whitelist !" -- MENSAGEM CASO NÃO TENHA WL -- (\n SIGNIFICA PRA PULAR A LINHA !)
            cancelEvent(true,Mensagem)
        else
            if IdWL == true then
                setElementData(source,ElementDataID,MeuID)
            end
        end
    end
end
addEventHandler("onPlayerConnect",root,Connect)

addCommandHandler("addwl", function(source,commandName,id)
    if id then
        local playerID = tonumber(id)
        if playerID then
            local result = dbPoll(dbQuery(db, "SELECT * FROM Whitelist WHERE ID = ?", playerID),-1)
            if #result ~= 0 then
                if result[1]["StatusWL"] == 0 then
                    dbExec(db,"UPDATE Whitelist SET StatusWL = ? WHERE ID = ?",1,playerID)
                    outputChatBox("#fffb00 ["..Sigla.."] #ffffffVocê liberou a WL do ID "..playerID.."",source,255,255,255,true)
                else
                    outputChatBox("#fffb00 ["..Sigla.."] #ffffffO ID "..playerID.." Já tem whitelist",source,255,255,255,true)
                end
            else
                outputChatBox("#fffb00 ["..Sigla.."] #ffffffO ID não localizado na database.",source,255,255,255,true)
            end
        end
    end
end)

addCommandHandler("remowl",function(source,commandName,id)
    if id then
        local playerID = tonumber(id)
        if playerID then
            local result = dbPoll(dbQuery(db, "SELECT * FROM Whitelist WHERE ID = ?",playerID),-1)
            if #result ~= 0 then
                if result[1]["StatusWL"] == 1 then
                    dbExec(db,"UPDATE Whitelist SET StatusWL = ? WHERE ID = ?",0,playerID)
                    outputChatBox("#fffb00 ["..Sigla.."] #ffffffVocê Removeu a Whitelist do [ID : "..playerID.."]",source,255,255,255,true)
                    local targetPlayer = getPlayerID(playerID) 
                    if targetPlayer then
                        kickPlayer(targetPlayer, "Console","Sua whiteList foi eemovida")
                    end
                else
                    outputChatBox("#fffb00 ["..Sigla.."] #ffffffO ID não está com a whitelist ativa.",source,255,255,255,true)
                end
            else
                outputChatBox("#fffb00 ["..Sigla.."] #ffffffO ID não localizado na database.",source,255,255,255,true)
            end
        end
    end
end)

addCommandHandler("id", function(source,commandName,id)
    if IdWL == true then
        if id then
            local playerID = tonumber(id)
            if playerID then
                local targetPlayer = getPlayerID(playerID)
                if targetPlayer then
                    local name = getPlayerName(targetPlayer)
                    outputChatBox ( "#00ff00✘ #ffffffINFO #00ff00✘➺ #ffffff Nome do Jogador #00ff00" .. getPlayerName(targetPlayer) .."", source, 255,255,255,true)
                    else
                        outputChatBox ( "#00ff00✘ #ffffffINFO #00ff00✘➺ #ffffff Jogador Não Localizado !", source, 255,255,255,true)
                    end
                else
                    outputChatBox ( "#00ff00✘ #ffffffINFO #00ff00✘➺ #ffffff ID Inválido !", source, 255,255,255,true)
                end
            else
                outputChatBox ( "#00ff00✘ #ffffffINFO #00ff00✘➺ #ffffff Digite /id ID para conferir o ID !", source, 255,255,255,true)
            end
        end
    end)
