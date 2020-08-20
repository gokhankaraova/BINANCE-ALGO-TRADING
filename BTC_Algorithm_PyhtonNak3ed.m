clear all;
clc

dataBTC = load('BTC1MData.mat');
sell_counter=0;
buy_counter_total=0;
gain=0;
total_comission=0;
for day=1
    clearvars -except starting_money dataBTC day sell_counter gain buy_counter_total total_comission
    BTCUSDT = (dataBTC.BTCUSDT1mdata(end-day*1440+1:end-(day-1)*1440,:)); %only last day data
    %     BTCUSDT = (dataBTC.BTCUSDT1mdata(end-30*1440+1:end-(0)*1440,:)); %only last day data
    open=table2array(BTCUSDT(:,2)); high =table2array(BTCUSDT(:,3));
    low =table2array(BTCUSDT(:,4)); close=table2array(BTCUSDT(:,5));
    
    starting_money = 120+sum(gain);
    current_money=starting_money;
    
    %% This Part Would be Present on API
    %%Moving Average
    MA_time=4; %moving average count
    for ii=MA_time:size(open,1)
        MA_open(ii)=0;
        for jj=0:MA_time-1
            MA_open(ii)= MA_open(ii)+ 1/MA_time*open(ii-jj);
        end
    end
    %%Moving Average Derivative
    for ii=2:size(open,1)
        MA_open_derivative(ii)= MA_open(ii)-MA_open(ii-1);
    end
    %% Algorithm Core
    buy_counter=0;
    for ii=MA_time+1:size(open,1) %skip first day
        open_old=open(ii-1);   high_old=high(ii-1);   low_old=low(ii-1);   close_old=close(ii-1);
        open_current=open(ii); high_current=high(ii); low_current=low(ii); close_current=close(ii);
        high_old_2ts = high(ii-2); high_old_3ts = high(ii-3); high_old_4ts = high(ii-4);
        high_max_olds = max([high_old_2ts,high_old_3ts,high_old_4ts]);
        %% buy
        if  current_money>30
            if open_old < close_old
                if open_old-low_old > close_old-open_old ||...
                        high_old-close_old > close_old-open_old
                    if high_old < high_max_olds
                        buy_counter=buy_counter+1; %BUY BUY BUY
                        buy_counter_total=buy_counter_total+1;
                        buy_x(buy_counter)=open_old-low_old;
                        buy_price(buy_counter)=open_current; %market price
                        buy_amount(buy_counter) = open_current*0.001; %Buy 100 worth of shares dollars amount
                        current_money=current_money-buy_amount(buy_counter); %Reduce current money
                        total_comission=total_comission+0.001*open_current*7.5000e-04;
                    end
                end
            end
            if open_old > close_old
                if close_old-low_old > open_old-close_old ||...
                        high_old-open_old > open_old-close_old
                    if high_old < high_max_olds
                        buy_counter=buy_counter+1; %BUY BUY BUY
                        buy_counter_total=buy_counter_total+1;
                        buy_x(buy_counter)=close_old-low_old;
                        buy_price(buy_counter)=open_current; %market price
                        buy_amount(buy_counter) = open_current*0.001; %Buy 100 worth of shares dollars amount
                        current_money=current_money-buy_amount(buy_counter); %Reduce current money
                        total_comission=total_comission+0.001*open_current*7.5000e-04;
                    end
                end
            end
        end
        %% sell
        if buy_counter >= 1
            for jj=1:buy_counter
                if  high_current-buy_price(jj) > 20*buy_x(jj)
                    current_money=current_money+buy_amount(jj)*(1+20*buy_x(jj)/buy_price(jj));
                    if buy_amount(jj)~=0
                        sell_counter=sell_counter+1;
                        total_comission=total_comission+0.001*open_current*7.5000e-04;
                    end
                    buy_amount(jj) = 0;
                end
            end
        end
    end
    active_money = buy_amount.*buy_price;
    total_money = current_money + sum(active_money)/close_current;
    gain(day)=(total_money-starting_money);
    %     % ['Earnings are %',num2str(gain)];
end
% total_comission
% sum(gain)
total_gain = sum(gain) - total_comission