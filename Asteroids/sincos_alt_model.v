module sincos (
    input   [7:0]  address,
    input     clock,
    output reg [35:0]  q
);

reg [35:0]mem[0:255];
reg [7:0]address_q;

initial
begin
	mem[8'h00] = 36'h00001FFFF;
	mem[8'h01] = 36'h00C91FFFE;
	mem[8'h02] = 36'h01921FFF6;
	mem[8'h03] = 36'h025B5FFEA;
	mem[8'h04] = 36'h03245FFD9;
	mem[8'h05] = 36'h03ED5FFC2;
	mem[8'h06] = 36'h04B61FFA7;
	mem[8'h07] = 36'h057F1FF87;
	mem[8'h08] = 36'h0647DFF62;
	mem[8'h09] = 36'h0710DFF38;
	mem[8'h0A] = 36'h07D95FF09;
	mem[8'h0B] = 36'h08A21FED6;
	mem[8'h0C] = 36'h096A9FE9D;
	mem[8'h0D] = 36'h0A331FE5F;
	mem[8'h0E] = 36'h0AFB9FE1D;
	mem[8'h0F] = 36'h0BC3DFDD5;
	mem[8'h10] = 36'h0C8BDFD89;
	mem[8'h11] = 36'h0D53DFD38;
	mem[8'h12] = 36'h0E1BDFCE1;
	mem[8'h13] = 36'h0EE39FC86;
	mem[8'h14] = 36'h0FAB5FC26;
	mem[8'h15] = 36'h1072DFBC1;
	mem[8'h16] = 36'h113A1FB58;
	mem[8'h17] = 36'h12011FAE9;
	mem[8'h18] = 36'h12C81FA75;
	mem[8'h19] = 36'h138EDF9FD;
	mem[8'h1A] = 36'h14559F980;
	mem[8'h1B] = 36'h151BDF8FD;
	mem[8'h1C] = 36'h15E21F876;
	mem[8'h1D] = 36'h16A81F7EA;
	mem[8'h1E] = 36'h176DDF75A;
	mem[8'h1F] = 36'h18339F6C4;
	mem[8'h20] = 36'h18F8DF629;
	mem[8'h21] = 36'h19BDDF58A;
	mem[8'h22] = 36'h1A82DF4E6;
	mem[8'h23] = 36'h1B475F43D;
	mem[8'h24] = 36'h1C0B9F38F;
	mem[8'h25] = 36'h1CCF9F2DD;
	mem[8'h26] = 36'h1D935F225;
	mem[8'h27] = 36'h1E56DF169;
	mem[8'h28] = 36'h1F1A1F0A8;
	mem[8'h29] = 36'h1FDCDEFE2;
	mem[8'h2A] = 36'h209F9EF18;
	mem[8'h2B] = 36'h2161DEE48;
	mem[8'h2C] = 36'h2223DED74;
	mem[8'h2D] = 36'h22E55EC9B;
	mem[8'h2E] = 36'h23A69EBBE;
	mem[8'h2F] = 36'h24679EADB;
	mem[8'h30] = 36'h25281E9F4;
	mem[8'h31] = 36'h25E85E908;
	mem[8'h32] = 36'h26A85E818;
	mem[8'h33] = 36'h27679E722;
	mem[8'h34] = 36'h2826DE629;
	mem[8'h35] = 36'h28E59E52A;
	mem[8'h36] = 36'h29A3DE427;
	mem[8'h37] = 36'h2A61DE31F;
	mem[8'h38] = 36'h2B1F5E212;
	mem[8'h39] = 36'h2BDC5E101;
	mem[8'h3A] = 36'h2C991DFEB;
	mem[8'h3B] = 36'h2D555DED0;
	mem[8'h3C] = 36'h2E111DDB1;
	mem[8'h3D] = 36'h2ECC9DC8D;
	mem[8'h3E] = 36'h2F875DB65;
	mem[8'h3F] = 36'h3041DDA38;
	mem[8'h40] = 36'h30FBDD907;
	mem[8'h41] = 36'h31B55D7D1;
	mem[8'h42] = 36'h326E5D696;
	mem[8'h43] = 36'h33271D557;
	mem[8'h44] = 36'h33DF1D413;
	mem[8'h45] = 36'h34969D2CB;
	mem[8'h46] = 36'h354D9D17E;
	mem[8'h47] = 36'h36041D02D;
	mem[8'h48] = 36'h36BA5CED8;
	mem[8'h49] = 36'h376F9CD7E;
	mem[8'h4A] = 36'h38249CC1F;
	mem[8'h4B] = 36'h38D91CABC;
	mem[8'h4C] = 36'h398CDC955;
	mem[8'h4D] = 36'h3A405C7E9;
	mem[8'h4E] = 36'h3AF31C679;
	mem[8'h4F] = 36'h3BA51C504;
	mem[8'h50] = 36'h3C56DC38B;
	mem[8'h51] = 36'h3D07DC20E;
	mem[8'h52] = 36'h3DB85C08C;
	mem[8'h53] = 36'h3E681BF06;
	mem[8'h54] = 36'h3F175BD7C;
	mem[8'h55] = 36'h3FC61BBED;
	mem[8'h56] = 36'h40741BA5B;
	mem[8'h57] = 36'h41215B8C4;
	mem[8'h58] = 36'h41CE1B728;
	mem[8'h59] = 36'h427A5B589;
	mem[8'h5A] = 36'h4325DB3E5;
	mem[8'h5B] = 36'h43D09B23D;
	mem[8'h5C] = 36'h447ADB091;
	mem[8'h5D] = 36'h45245AEE0;
	mem[8'h5E] = 36'h45CD5AD2C;
	mem[8'h5F] = 36'h46759AB73;
	mem[8'h60] = 36'h471D1A9B6;
	mem[8'h61] = 36'h47C3DA7F6;
	mem[8'h62] = 36'h486A1A631;
	mem[8'h63] = 36'h490F5A468;
	mem[8'h64] = 36'h49B41A29A;
	mem[8'h65] = 36'h4A581A0C9;
	mem[8'h66] = 36'h4AFB99EF4;
	mem[8'h67] = 36'h4B9E19D1B;
	mem[8'h68] = 36'h4C3FD9B3E;
	mem[8'h69] = 36'h4CE11995D;
	mem[8'h6A] = 36'h4D8199778;
	mem[8'h6B] = 36'h4E211958F;
	mem[8'h6C] = 36'h4EC0193A2;
	mem[8'h6D] = 36'h4F5E191B1;
	mem[8'h6E] = 36'h4FFB98FBD;
	mem[8'h6F] = 36'h509818DC4;
	mem[8'h70] = 36'h5133D8BC8;
	mem[8'h71] = 36'h51CED89C8;
	mem[8'h72] = 36'h5269187C4;
	mem[8'h73] = 36'h5302985BC;
	mem[8'h74] = 36'h539B583B1;
	mem[8'h75] = 36'h5433181A2;
	mem[8'h76] = 36'h54CA17F8F;
	mem[8'h77] = 36'h556057D78;
	mem[8'h78] = 36'h55F5D7B5E;
	mem[8'h79] = 36'h568A57940;
	mem[8'h7A] = 36'h571E1771E;
	mem[8'h7B] = 36'h57B0D74F9;
	mem[8'h7C] = 36'h5842D72D1;
	mem[8'h7D] = 36'h58D4170A4;
	mem[8'h7E] = 36'h596496E74;
	mem[8'h7F] = 36'h59F3D6C41;
	mem[8'h80] = 36'h5A8296A0A;
	mem[8'h81] = 36'h5B10567CF;
	mem[8'h82] = 36'h5B9D16592;
	mem[8'h83] = 36'h5C2916350;
	mem[8'h84] = 36'h5CB45610B;
	mem[8'h85] = 36'h5D3E55EC3;
	mem[8'h86] = 36'h5DC795C78;
	mem[8'h87] = 36'h5E5015A29;
	mem[8'h88] = 36'h5ED7957D7;
	mem[8'h89] = 36'h5F5E15581;
	mem[8'h8A] = 36'h5FE3D5328;
	mem[8'h8B] = 36'h6068950CC;
	mem[8'h8C] = 36'h60EC54E6D;
	mem[8'h8D] = 36'h616F14C0A;
	mem[8'h8E] = 36'h61F1149A4;
	mem[8'h8F] = 36'h62721473B;
	mem[8'h90] = 36'h62F2144CF;
	mem[8'h91] = 36'h637114260;
	mem[8'h92] = 36'h63EF53FEE;
	mem[8'h93] = 36'h646C53D78;
	mem[8'h94] = 36'h64E893B00;
	mem[8'h95] = 36'h6563D3884;
	mem[8'h96] = 36'h65DE13606;
	mem[8'h97] = 36'h665753384;
	mem[8'h98] = 36'h66CF930FF;
	mem[8'h99] = 36'h6746D2E78;
	mem[8'h9A] = 36'h67BD12BEE;
	mem[8'h9B] = 36'h683252960;
	mem[8'h9C] = 36'h68A6926D0;
	mem[8'h9D] = 36'h691A1243D;
	mem[8'h9E] = 36'h698C521A8;
	mem[8'h9F] = 36'h69FD91F0F;
	mem[8'hA0] = 36'h6A6D91C74;
	mem[8'hA1] = 36'h6ADCD19D6;
	mem[8'hA2] = 36'h6B4B11735;
	mem[8'hA3] = 36'h6BB811491;
	mem[8'hA4] = 36'h6C24511EB;
	mem[8'hA5] = 36'h6C8F50F42;
	mem[8'hA6] = 36'h6CF950C97;
	mem[8'hA7] = 36'h6D62509E9;
	mem[8'hA8] = 36'h6DCA10738;
	mem[8'hA9] = 36'h6E3110485;
	mem[8'hAA] = 36'h6E96D01D0;
	mem[8'hAB] = 36'h6EFB4FF18;
	mem[8'hAC] = 36'h6F5F0FC5D;
	mem[8'hAD] = 36'h6FC18F9A0;
	mem[8'hAE] = 36'h70230F6E1;
	mem[8'hAF] = 36'h70838F41F;
	mem[8'hB0] = 36'h70E2CF15B;
	mem[8'hB1] = 36'h71410EE94;
	mem[8'hB2] = 36'h719E4EBCC;
	mem[8'hB3] = 36'h71FA4E901;
	mem[8'hB4] = 36'h72554E633;
	mem[8'hB5] = 36'h72AF0E364;
	mem[8'hB6] = 36'h7307CE092;
	mem[8'hB7] = 36'h735F8DDBE;
	mem[8'hB8] = 36'h73B60DAE9;
	mem[8'hB9] = 36'h740B4D810;
	mem[8'hBA] = 36'h745F8D536;
	mem[8'hBB] = 36'h74B2CD25A;
	mem[8'hBC] = 36'h7504CCF7C;
	mem[8'hBD] = 36'h7555CCC9C;
	mem[8'hBE] = 36'h75A58C9B9;
	mem[8'hBF] = 36'h75F44C6D5;
	mem[8'hC0] = 36'h7641CC3EF;
	mem[8'hC1] = 36'h768E0C107;
	mem[8'hC2] = 36'h76D94BE1D;
	mem[8'hC3] = 36'h77234BB32;
	mem[8'hC4] = 36'h776C4B844;
	mem[8'hC5] = 36'h77B40B555;
	mem[8'hC6] = 36'h77FACB264;
	mem[8'hC7] = 36'h78404AF71;
	mem[8'hC8] = 36'h78848AC7D;
	mem[8'hC9] = 36'h78C7CA987;
	mem[8'hCA] = 36'h7909CA68F;
	mem[8'hCB] = 36'h794A8A396;
	mem[8'hCC] = 36'h798A4A09B;
	mem[8'hCD] = 36'h79C889D9E;
	mem[8'hCE] = 36'h7A0609AA1;
	mem[8'hCF] = 36'h7A42097A1;
	mem[8'hD0] = 36'h7A7D094A0;
	mem[8'hD1] = 36'h7AB6C919E;
	mem[8'hD2] = 36'h7AEF88E9A;
	mem[8'hD3] = 36'h7B26C8B95;
	mem[8'hD4] = 36'h7B5D0888F;
	mem[8'hD5] = 36'h7B9208587;
	mem[8'hD6] = 36'h7BC60827E;
	mem[8'hD7] = 36'h7BF887F73;
	mem[8'hD8] = 36'h7C2A07C68;
	mem[8'hD9] = 36'h7C5A4795B;
	mem[8'hDA] = 36'h7C894764D;
	mem[8'hDB] = 36'h7CB74733E;
	mem[8'hDC] = 36'h7CE3C702E;
	mem[8'hDD] = 36'h7D0F46D1D;
	mem[8'hDE] = 36'h7D3986A0B;
	mem[8'hDF] = 36'h7D62866F7;
	mem[8'hE0] = 36'h7D8A463E3;
	mem[8'hE1] = 36'h7DB1060CE;
	mem[8'hE2] = 36'h7DD685DB7;
	mem[8'hE3] = 36'h7DFA85AA0;
	mem[8'hE4] = 36'h7E1D85788;
	mem[8'hE5] = 36'h7E3F4546F;
	mem[8'hE6] = 36'h7E6005156;
	mem[8'hE7] = 36'h7E7F44E3B;
	mem[8'hE8] = 36'h7E9D44B20;
	mem[8'hE9] = 36'h7EBA44804;
	mem[8'hEA] = 36'h7ED6044E8;
	mem[8'hEB] = 36'h7EF0441CB;
	mem[8'hEC] = 36'h7F0983EAD;
	mem[8'hED] = 36'h7F2183B8E;
	mem[8'hEE] = 36'h7F384386F;
	mem[8'hEF] = 36'h7F4E0354F;
	mem[8'hF0] = 36'h7F624322F;
	mem[8'hF1] = 36'h7F7542F0F;
	mem[8'hF2] = 36'h7F8742BEE;
	mem[8'hF3] = 36'h7F97C28CC;
	mem[8'hF4] = 36'h7FA7425AA;
	mem[8'hF5] = 36'h7FB582288;
	mem[8'hF6] = 36'h7FC241F65;
	mem[8'hF7] = 36'h7FCE01C43;
	mem[8'hF8] = 36'h7FD88191F;
	mem[8'hF9] = 36'h7FE1C15FC;
	mem[8'hFA] = 36'h7FE9C12D8;
	mem[8'hFB] = 36'h7FF080FB5;
	mem[8'hFC] = 36'h7FF640C91;
	mem[8'hFD] = 36'h7FFA8096D;
	mem[8'hFE] = 36'h7FFD80648;
	mem[8'hFF] = 36'h7FFF80324;
end

always @(posedge clock)
begin
    address_q <= address;
    q <= mem[address_q];
end
endmodule
