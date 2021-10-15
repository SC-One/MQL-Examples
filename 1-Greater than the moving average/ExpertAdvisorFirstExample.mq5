//+------------------------------------------------------------------+
//|                                  Greater than the moving average |
//|                                           Copyright 2020, SC-One |
//|                           https://github.com/SC-One/MQL-Examples |
//+------------------------------------------------------------------+

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Let's demonstrate how the OrderSend() function works in a simple expert advisor. This trading strategy will
//open a buy market order when the current close price is greater than the moving average, or open a sell
//market order when the close price is less than the moving average. The user has the option to specify a stop
//loss and take profit in points, as well as a trade volume
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#property copyright "SC-One"
#property link      "https://github.com/SC-One/MQL-Examples"
#property version   "1.0.0"
// Input variables
input double TradeVolume=0.1;
input int StopLoss=1000;
input int TakeProfit=1000;
input int MAPeriod=10;
// Global variables
bool glBuyPlaced, glSellPlaced;
// OnTick() event handler
void OnTick() {
// Trade structures
 MqlTradeRequest request;
 MqlTradeResult result;
 ZeroMemory(request);
// Moving average
 double ma[];
 ArraySetAsSeries(ma, true);
 int maHandle=iMA(_Symbol, 0, MAPeriod, MODE_SMA, 0, PRICE_CLOSE);
 CopyBuffer(maHandle, 0, 0, 1, ma);

// Close price
 double close[];
 ArraySetAsSeries(close, true);
 CopyClose(_Symbol, 0, 0, 1, close);

// Current position information
 bool openPosition = PositionSelect(_Symbol);
 long positionType = PositionGetInteger(POSITION_TYPE);

 double currentVolume = 0;
 if(openPosition == true) currentVolume = PositionGetDouble(POSITION_VOLUME);
// Open buy market order
 if(close[0] > ma[0] && glBuyPlaced == false
    && (positionType != POSITION_TYPE_BUY || openPosition == false)) {
  request.action = TRADE_ACTION_DEAL;
  request.type = ORDER_TYPE_BUY;
  request.symbol = _Symbol;
  request.volume = TradeVolume + currentVolume;
  request.type_filling = ORDER_FILLING_FOK;
  request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  request.sl = 0;
  request.tp = 0;
  request.deviation = 50;
  OrderSend(request, result);
// Modify SL/TP
  if(result.retcode == TRADE_RETCODE_PLACED || result.retcode == TRADE_RETCODE_DONE) {
   request.action = TRADE_ACTION_SLTP;
   do Sleep(100);
   while(PositionSelect(_Symbol) == false);
   double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   if(StopLoss > 0) request.sl = positionOpenPrice - (StopLoss * _Point);
   if(TakeProfit > 0) request.tp = positionOpenPrice + (TakeProfit * _Point);
   if(request.sl > 0 && request.tp > 0) OrderSend(request, result);
   glBuyPlaced = true;
   glSellPlaced = false;
  }
 }
// Open sell market order
 else if(close[0] < ma[0] && glSellPlaced == false && positionType != POSITION_TYPE_SELL) {
  request.action = TRADE_ACTION_DEAL;
  request.type = ORDER_TYPE_SELL;
  request.symbol = _Symbol;
  request.volume = TradeVolume + currentVolume;
  request.type_filling = ORDER_FILLING_FOK;
  request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
  request.sl = 0;
  request.tp = 0;
  request.deviation = 50;
  OrderSend(request, result);
// Modify SL/TP
  if((result.retcode == TRADE_RETCODE_PLACED || result.retcode == TRADE_RETCODE_DONE)
     && (StopLoss > 0 || TakeProfit > 0)) {
   request.action = TRADE_ACTION_SLTP;
   do Sleep(100);
   while(PositionSelect(_Symbol) == false);
   double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   if(StopLoss > 0) request.sl = positionOpenPrice + (StopLoss * _Point);
   if(TakeProfit > 0) request.tp = positionOpenPrice - (TakeProfit * _Point);
   if(request.sl > 0 && request.tp > 0) OrderSend(request, result);
   glBuyPlaced = false;
   glSellPlaced = true;
  }
 }
}
//+------------------------------------------------------------------+
