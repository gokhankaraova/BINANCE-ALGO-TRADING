clear all;clc
dataBTC = load('BTC1MData.mat');
BTCUSDT = (dataBTC.BTCUSDT1mdata(end-4:end,:)); %only last day data
open=table2array(BTCUSDT(:,2)); high =table2array(BTCUSDT(:,3));
low =table2array(BTCUSDT(:,4)); close=table2array(BTCUSDT(:,5));
balance=100; tt=5;
high_max_olds = max([high(ii-2),high(ii-3),high(ii-4)]);
%% buy
if high(tt-1) < high_max_olds
    if open(tt-1) < close(tt-1)
        if open(tt-1)-low(tt-1) > close(tt-1)-open(tt-1) ||...
                high(tt-1)-close(tt-1) > close(tt-1)-open(tt-1)
            buy_x=open(tt-1)-low(tt-1);
            buy_price=open(tt);
            buy_amount=30;
        end
    end
    if open(tt-1) > close(tt-1)
        if close(tt-1)-low(tt-1) > open(tt-1)-close(tt-1) ||...
                high(tt-1)-open(tt-1) > open(tt-1)-close(tt-1)
            buy_x=close(tt-1)-low(tt-1);
            buy_price=open(tt);
            buy_amount=30;
        end
    end
end
%% sell
if  high(tt)-buy_price > 10*buy_x
    sell_amount=buy_amount*(1+10*buy_x/buy_price);
end