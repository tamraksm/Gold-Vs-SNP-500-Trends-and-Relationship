
%LET first_file =C:\Users\sanjay\Desktop\final project\gold.html;
%LET first_dataname = gold;
%LET second_file =C:\Users\sanjay\Desktop\final project\Snp500.html;
%LET second_dataname = snp;

data &first_dataname;
	infile "&first_file"
	delimiter = '>';
	input string $ 32767. @@;
	n = _N_;
	a = index(string, "Dec 31, 2015"); 
		if a = 0 then b = a;
		else call symput('c', n); 
run;

data &second_dataname;
	infile "&second_file"
		delimiter = '>';
	input string $ 32767. @@;
	n = _N_;
	a = index(string, "Dec 31, 2015");
	if a = 0 then b = a;
	else call symput('c', n);
run;

data gold2;
	infile "&first_file"
		firstobs = &c end = eof
		delimiter = '<';
	input @'noWrap">' old_date_g $ 12. @'Font">' Price_g  @'<td>' Open_g  @'<td>' High_g  
		  @'<td>' Low_g  @'">' Vol_g$ @'">' Pct_Change_g$;
	label old_date_g = "Date"
	  	  Price_g = "Price of gold future ($)"
	      Open_g = "Open Price of gold futures ($)"
	      High_g = "High price of gold futures ($)"
	      Low_g = "Low price of gold futures ($)"
	      Vol_g = "Volume of gold futures"
	      Pct_change_g = "Percentage change of gold futures";
run;

data gold2;
	set gold1;
	Date = input (old_date_g, anydtdte12.);
	format Date yymmdd8.;
	vol_g = compress(Vol_g, 'K') *1000;
	drop old_date_g;
run;


proc sort data=gold2;
	by Date;
run;

title 'S&P Historical Prices';


data snp1;
	infile "&second_file"
		firstobs = &c end = eof
		delimiter = '<';
	input @'bold noWrap">' old_date_s $ 12. @'Font">' Price_s  @'<td>' Open_s  @'<td>' High_s  @'<td>' Low_s  @'">' Vol_s$ @'">' Pct_Change_s$;
	label old_date_s = "Date"
			Price_s = "Price of S&P 500 ($)"
			Open_s = "Open Price of S&P 500 ($)"
			High_s = "High price of S&P 500 ($)"
			Low_s = "Low price of S&P 500 ($)"
			Vol_s = "Volume of S&P 500"
			Pct_change_s = "Percentage change of S&P 500";
run;

data snp2;
	set snp1;
		Date = input (old_date_s, anydtdte12.);
		format Date yymmdd8.;
		vol_s = compress(Vol_s, 'K') *1000;
		keep date price_s open_s high_s low_s vol_s pct_change_s;
	drop old_date_s;
run;


proc sort data=snp2;
	by Date;
run;

data combined;
	merge gold2 snp2; 
	by date;
	ratio_gs = (price_g/price_s)*1000;
    ratio_sg = (price_S/price_g)*1000;
	label ratio_gs ="(Ratio of price of gold to snp500)times 1000";
	label ratio_sg ="(Ratio of price of snp500 to gold)times 1000";
	drop vol_s;		
run;

ods rtf bodytitle file = "C:\Users\sanjay\Desktop\final project\final.rtf";
%MACRO chart1(tie=, by=);
proc sgplot data = combined;
	title &tie;
	series x = date y = price_g;
	series x = date y = &by; 
	xaxis label = "Years (2006- 2016)";
	yaxis label = " Price Range($)";
run;

%MEND chart1;
%chart1(tie="Gold Futures VS Standard and Poor's 500 Index", by= price_s)
%chart1(tie= "Gold Futures VS (Ratio of price of snp500 to gold)times 1000 ", by=ratio_sg)
%chart1(tie= 'S&P 500 VS (Ratio of price of gold to snp500)times 1000 ',by =  ratio_gs)


proc corr data= combined 
	outp= combined1 nomiss noprob nosimple;
	var  price_s price_g;
run;

ods rtf close;






