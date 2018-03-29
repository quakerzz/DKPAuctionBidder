local DKPAuctionBidder_Identifier = "DKPAuctionBidder"
local DKPAuctionBidder_SOTAprefix = "SOTAv1"

local DKPAuctionBidder_CHAT_END					= "|r"
local DKPAuctionBidder_COLOUR_INTRO				= "|c80F0F0F0"
local DKPAuctionBidder_COLOUR_CHAT				= "|c8040A0F8"  
local DKPAuctionBidder_AuctionState             = 0 -- 0: No Auction, 1: Auction - no bids, 2: Auction - with bids, 3: Auction Paused
local DKPAuctionBidder_PlayerDKP                = 0
local DKPAuctionBidder_SOTA_Master              = ""
local DKPAuctionBidder_SubmitBidTimer           = 1 -- time between to bid submissions in seconds
local DKPAuctionBidder_SubmitBidFlag            = 1 -- 1: Able to submit bid, 0: Not able to submit bid

local currentbid = {}

function DKPAuctionBidder_OnEvent(event, arg1, arg2, arg3, arg4, arg5)
    if (event == "CHAT_MSG_ADDON") then
        DKPAuctionBidder_OnChatMsgAddon(event, arg1, arg2, arg3, arg4, arg5)
    end
end

function DKPAuctionBidder_OnLoad()
    this:RegisterEvent("ADDON_LOADED");
    this:RegisterEvent("CHAT_MSG_ADDON");
    DKPList_MinimapButtonFrame:Show()
    DKPAuctionBidder_GetPlayerDKP()
end

function DKPAuctionBidder_BidMinOnClick()
    if DKPAuctionBidder_SubmitBidFlag == 1 then
        local sendtext = "bid min"
        SendAddonMessage(DKPAuctionBidder_Identifier, sendtext, "RAID")
        DKPAuctionBidder_SubmitBidFlag = 0
    end
end

function DKPAuctionBidder_BidMaxOnClick()
    DKPAuctionBidderMaxBidConfirmationFrame:Show()
end

function DKPAuctionBidder_BidXOnEnter(dkp)
    if DKPAuctionBidder_SubmitBidFlag == 1 then
        local sendtext = "bid " ..dkp
        SendAddonMessage(DKPAuctionBidder_Identifier, sendtext, "RAID")
        DKPAuctionBidder_SubmitBidFlag = 0
    end
end

function DKPAuctionBidder_MaxBidConfirmOnClick()
    if DKPAuctionBidder_SubmitBidFlag == 1 then
        local sendtext = "bid max"
        SendAddonMessage(DKPAuctionBidder_Identifier, sendtext, "RAID")
        DKPAuctionBidderMaxBidConfirmationFrame:Hide()
        DKPAuctionBidder_SubmitBidFlag = 0
    end
end

function DKPAuctionBidder_MaxBidDeclineOnClick()
    DKPAuctionBidderMaxBidConfirmationFrame:Hide()
end

local DKPAuctionBidder_Timer = 0

function DKPAuctionBidder_BidFrameOnUpdate(elapsed)
    DKPAuctionBidder_Timer = DKPAuctionBidder_Timer + elapsed
    if DKPAuctionBidder_Timer > DKPAuctionBidder_SubmitBidTimer then
        DKPAuctionBidder_Timer = 0
        DKPAuctionBidder_SubmitBidFlag = 1
    end
end

function DKPAuctionBidder_MinimapButtonOnClick()
    DKPAuctionBidderUIFrame:Show()
    if DKPAuctionBidder_AuctionState == 0 then
        getglobal("DKPAuctionBidderHighestBidTextButtonText"):SetText("Highest Bid: No Auction")
    elseif DKPAuctionBidder_AuctionState == 1 then
        getglobal("DKPAuctionBidderHighestBidTextButtonText"):SetText("Highest Bid: Auction Running - No Bids")
    elseif DKPAuctionBidder_AuctionState == 2 then
        getglobal("DKPAuctionBidderHighestBidTextButtonText"):SetText("Highest Bid: " ..currentbid[3] .." DKP by "..currentbid[4])
    elseif DKPAuctionBidder_AuctionState == 3 then
        getglobal("DKPAuctionBidderHighestBidTextButtonText"):SetText("Highest Bid: Auction Paused")
    end
    DKPAuctionBidder_GetPlayerDKP()
end

function DKPAuctionBidder_CloseUI()
    DKPAuctionBidderMaxBidConfirmationFrame:Hide()
    DKPAuctionBidderUIFrame:Hide()
end

function DKPAuctionBidder_OnChatMsgAddon(event, prefix, msg, channel, sender)
    if prefix == "SOTA_reply_DKPAuctionBidder" then
        if string.find(msg, UnitName("player")) == 1 then
            local message = string.sub(msg, string.len(UnitName("player"))+1)
            DEFAULT_CHAT_FRAME:AddMessage(DKPAuctionBidder_COLOUR_CHAT .. message .. DKPAuctionBidder_CHAT_END)
        end
    end

    local message = string.sub(msg, 1, string.len("HIGEST_BID")+1)
    local text = getglobal("DKPAuctionBidderHighestBidTextButtonText"):GetText()

    currentbid = DKPAuctionBidder_SplitString(msg)

    if prefix == DKPAuctionBidder_SOTAprefix then
        if msg == "SOTA_AUCTION_START" then
            getglobal("DKPAuctionBidderHighestBidTextButtonText"):SetText("Highest Bid: Auction Running - No Bids")
            DKPAuctionBidder_GetPlayerDKP()
            DKPAuctionBidderUIFrame:Show()
            DKPAuctionBidder_AuctionState = 1
        elseif message == "HIGHEST_BID" then
            --if currentbid[4] == UnitName("player") then currentbid[4] = currentbid[4] .."(you)"
            getglobal("DKPAuctionBidderHighestBidTextButtonText"):SetText("Highest Bid: " ..currentbid[3] .." DKP by "..currentbid[4])
            DKPAuctionBidder_AuctionState = 2
        elseif msg == "SOTA_AUCTION_FINISH" or msg == "SOTA_AUCTION_CANCEL" then
            getglobal("DKPAuctionBidderHighestBidTextButtonText"):SetText("Highest Bid: No Auction")
            DKPAuctionBidder_AuctionState = 0
        elseif msg == "SOTA_AUCTION_PAUSE" then
            getglobal("DKPAuctionBidderHighestBidTextButtonText"):SetText("Highest Bid: Auction Paused")
            DKPAuctionBidder_AuctionState = 3
        end

        if msg == "SOTAMASTER" then
            DKPAuctionBidder_SOTA_Master = sender
        end
    end
end

function DKPAuctionBidder_GetPlayerDKP()
	local memberCount = GetNumGuildMembers();
	local note
	for n=1,memberCount,1 do
		local name, rank, _, _, class, zone, publicnote, officernote, online = GetGuildRosterInfo(n)

        if name == UnitName("player") then
		    if not zone then
		    	zone = "";
		    end

		    note = publicnote

		    if not note or note == "" then
		    	note = "<0>";
		    end
        
		    if not online then
		    	online = 0;
		    end
        
		    local _, _, dkp = string.find(note, "<(-?%d*)>")
		    if not dkp then
		    	dkp = 0;
            end
            DKPAuctionBidder_PlayerDKP = (1*dkp)
        end
    end
    getglobal("DKPAuctionBidderPlayerDKPButtonText"):SetText("Your DKP: " ..DKPAuctionBidder_PlayerDKP)
end

function DKPAuctionBidder_SplitString(inputstr)
    local t={} ; i=1
    for w in string.gfind(inputstr, "%w+") do
            t[i] = w
            i = i + 1
    end
    return t
end