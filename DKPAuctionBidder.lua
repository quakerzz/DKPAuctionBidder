local DKPAuctionBidder_Identifier = "DKPAuctionBidder"
local DKPAuctionBidder_SOTAprefix = "SOTAv1"

local DKPAuctionBidder_CHAT_END					= "|r"
local DKPAuctionBidder_COLOUR_INTRO				= "|c80F0F0F0"
local DKPAuctionBidder_COLOUR_CHAT				= "|c8040A0F8"

function DKPAuctionBidder_OnEvent(event, arg1, arg2, arg3, arg4, arg5)
    if (event == "CHAT_MSG_ADDON") then
        DKPAuctionBidder_OnChatMsgAddon(event, arg1, arg2, arg3, arg4, arg5)
    end
end

function DKPAuctionBidder_OnLoad()
    this:RegisterEvent("ADDON_LOADED");
    this:RegisterEvent("CHAT_MSG_ADDON");
    DKPList_MinimapButtonFrame:Show()
end

function DKPAuctionBidder_BidMinOnClick()
    local sendtext = "bid min"
    SendAddonMessage(DKPAuctionBidder_Identifier, sendtext, "RAID")
end

function DKPAuctionBidder_BidMaxOnClick()
    DKPAuctionBidderMaxBidConfirmationFrame:Show()
end

function DKPAuctionBidder_BidXOnEnter(dkp)
    local sendtext = "bid " ..dkp
    SendAddonMessage(DKPAuctionBidder_Identifier, sendtext, "RAID")
end

function DKPAuctionBidder_MaxBidConfirmOnClick()
    local sendtext = "bid max"
    SendAddonMessage(DKPAuctionBidder_Identifier, sendtext, "RAID")
    DKPAuctionBidderMaxBidConfirmationFrame:Hide()
end

function DKPAuctionBidder_MaxBidDeclineOnClick()
    DKPAuctionBidderMaxBidConfirmationFrame:Hide()
end

function DKPAuctionBidder_MinimapButtonOnClick()
    DKPAuctionBidderUIFrame:Show()
end

function DKPAuctionBidder_OnChatMsgAddon(event, prefix, msg, channel, sender)
    if prefix == "SOTA_reply_DKPAuctionBidder" then
        DEFAULT_CHAT_FRAME:AddMessage(DKPAuctionBidder_COLOUR_CHAT .. msg .. DKPAuctionBidder_CHAT_END)
    end

    local message = string.sub(msg, 1, string.len("HIGEST_BID")+1)
    local text = getglobal("DKPAuctionBidderHighestBidTextButtonText"):GetText()

    local currentbid = DKPAuctionBidder_SplitString(msg)

    if prefix == DKPAuctionBidder_SOTAprefix then
        if msg == "SOTA_AUCTION_START" then
            DKPAuctionBidderUIFrame:Show()
            getglobal("DKPAuctionBidderHighestBidTextButtonText"):SetText("Highest Bid: No Bids")
        elseif message == "HIGHEST_BID" then
            if currentbid[4] == UnitName("player") then currentbid[4] = currentbid[4] .."(you)"
            getglobal("DKPAuctionBidderHighestBidTextButtonText"):SetText("Highest Bid: " ..currentbid[3] " DKP by "..currentbid[4])
        elseif msg == "SOTA_AUCTION_FINISH" then
            getglobal("DKPAuctionBidderHighestBidTextButtonText"):SetText("Highest Bid: No Auction")
        end
    end
end

function DKPAuctionBidder_SplitString(inputstr)
    local t={} ; i=1
    for w in string.gfind(inputstr, "%w+") do
            t[i] = w
            i = i + 1
    end
    return t
end