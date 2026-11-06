# sstable.ae layout

    Code
      print(plain(tab$table)[1:10, ])
    Output
            [,1]                         [,2]        [,3]                    
       [1,] ""                           ""          "Sham procedure (N=135)"
       [2,] "Type of adverse event"      "n episode" "n patient"             
       [3,] "Any selected adverse event" "283"       "88/135 (65%)"          
       [4,] "- Grade N/A"                "3"         "3/135 (2%)"            
       [5,] "- Grade I"                  "26"        "25/135 (19%)"          
       [6,] "- Grade II"                 "208"       "79/135 (59%)"          
       [7,] "- Grade III"                "40"        "25/135 (19%)"          
       [8,] "- Grade IV"                 "6"         "6/135 (4%)"            
       [9,] "Nausea"                     "0"         "0/135 (0%)"            
      [10,] "Back pain"                  "1"         "1/135 (1%)"            
            [,4]        [,5]                            [,6]     
       [1,] ""          "Intrathecal treatment (N=136)" "p value"
       [2,] "n episode" "n patient"                     ""       
       [3,] "251"       "84/136 (62%)"                  "0.559"  
       [4,] "3"         "3/136 (2%)"                    ""       
       [5,] "32"        "26/136 (19%)"                  ""       
       [6,] "192"       "73/136 (54%)"                  ""       
       [7,] "19"        "17/136 (12%)"                  ""       
       [8,] "5"         "5/136 (4%)"                    ""       
       [9,] "1"         "1/136 (1%)"                    ""       
      [10,] "1"         "1/136 (1%)"                    ""       

---

    Code
      ft_footer_text(sstable.ae(ae, fid, id.var = "usubjid", aetype.var = "ctcaename",
        arm.var = "Arm", footer = "My note"))
    Output
      [1] "n episode: total number of events"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
      [2] "n patient: number of patients with at least one event"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
      [3] "p-values are based on chi-square test if expected value under null hypothesis > 1 in each cell; otherwise Fisher's exact test is usedp-values are based on chi-square test if expected value under null hypothesis > 1 in each cell; otherwise Fisher's exact test is usedp-values are based on chi-square test if expected value under null hypothesis > 1 in each cell; otherwise Fisher's exact test is usedp-values are based on chi-square test if expected value under null hypothesis > 1 in each cell; otherwise Fisher's exact test is usedp-values are based on chi-square test if expected value under null hypothesis > 1 in each cell; otherwise Fisher's exact test is usedp-values are based on chi-square test if expected value under null hypothesis > 1 in each cell; otherwise Fisher's exact test is used"
      [4] "My noteMy noteMy noteMy noteMy noteMy note"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    

# sstable.baseline layout

    Code
      print(plain(tab$table))
    Output
           [,1]             [,2]  [,3]                     [,4] 
      [1,] ""               ""    "Sham procedure (N=135)" ""   
      [2,] "Characteristic" "n"   "Summary statistic"      "n"  
      [3,] "age"            "135" "51; 50 (41-60)"         "136"
      [4,] "sex"            "135" ""                       "136"
      [5,] "- F"            ""    "22 (16%)"               ""   
      [6,] "- M"            ""    "113 (84%)"              ""   
      [7,] "bmi"            "135" "21; 21 (20-23)"         "136"
           [,5]                            [,6]  [,7]                [,8]     
      [1,] "Intrathecal treatment (N=136)" ""    "Total (N=271)"     "p value"
      [2,] "Summary statistic"             "n"   "Summary statistic" ""       
      [3,] "48; 46 (38-57)"                "271" "49; 48 (39-59)"    "0.0812" 
      [4,] ""                              "271" ""                  "1"      
      [5,] "22 (16%)"                      ""    "44 (16%)"          ""       
      [6,] "114 (84%)"                     ""    "227 (84%)"         ""       
      [7,] "22; 21 (20-23)"                "271" "22; 21 (20-23)"    "0.371"  

---

    Code
      tab$footer
    Output
      [1] "N is number of all patients, n is number of patients with non-missing value."                                                             
      [2] "Summary statistic is absolute count (%) for categorical variable(s) and mean; median (Q1-Q3) for numeric variable(s)."                    
      [3] "p-values were based on Fisher's exact test for categorical variable(s) and Kruskal-Wallis/Mann-Whitney U-test for continuous variable(s)."

# sstable.survcomp layout

    Code
      print(plain(sstable.survcomp(Surv(time, status) ~ arm, d, flextable = FALSE)$
        table))
    Output
        ────────────────────────────────────────────────────────────────────────────
          Endpoint       2 (n=90)       1 (n=137)      Comparison     Test for      
                                                                      proportional  
                                                                      hazards       
                         events/n       events/n       HR (95%CI);    p-value       
                         (risk [%])     (risk [%])     p-value                      
          status         53/90          111/137        0.59 (0.43,    0.1           
                         (91.68)        (96.40)        0.82);                       
                                                       p=0.00176                    
          time                                                                      
          - Median       426.00         270.00                                      
          (95%CI)        (348.00,       (218.00,                                    
                         550.00)        320.00)                                     
          - Lower IQR    226.00         147.00                                      
          (95%CI)        (186.00,       (110.00,                                    
                         340.00)        179.00)                                     
          - Upper IQR    687.00         457.00                                      
          (95%CI)        (550.00, NA)   (387.00,                                    
                                        574.00)                                     
        ────────────────────────────────────────────────────────────────────────────
      
      Column names: V1, V2, V3, V4, V5

---

    Code
      print(plain(sstable.survcomp(Surv(time, status) ~ arm, d, compare.method = "rmst",
      compare.args = list(type = "ratio"), flextable = FALSE)$table))
    Output
       ─────────────────────────────────────────────────────────────────────────────
         Endpoint           2 (n=90)           1 (n=137)          Comparison        
                            events/n (risk     events/n (risk     RMST ratio        
                            [%])               [%])               (95%CI); p-value  
         status             53/90 (91.68)      111/137 (96.40)    1.40 (1.15,       
                                                                  1.71); p=<0.001   
         time                                                                       
         - Median (95%CI)   426.00 (348.00,    270.00 (218.00,                      
                            550.00)            320.00)                              
         - Lower IQR        226.00 (186.00,    147.00 (110.00,                      
         (95%CI)            340.00)            179.00)                              
         - Upper IQR        687.00 (550.00,    457.00 (387.00,                      
         (95%CI)            NA)                574.00)                              
       ─────────────────────────────────────────────────────────────────────────────
      
      Column names: V1, V2, V3, V4

# sstable.survcomp.subgroup layout

    Code
      print(plain(sstable.survcomp.subgroup(Surv(time, status) ~ arm, ~ph.ecog, data = d,
      flextable = FALSE)$table))
    Output
      ───────────────────────────────────────────────────────────────────────────────
        Subgroup     2 (n=90)     1 (n=136)    Comparison   Test for     Test for    
                                                            proportion   heterogene  
                                                            al hazards   ity         
                     events/n     events/n     HR           p-value      p-value     
                     (risk [%])   (risk [%])   (95%CI);                              
                                               p-value                               
        All          53/90        110/136      0.60         0.108                    
        patients     (91.68)      (96.38)      (0.43,                                
                                               0.83);                                
                                               p=0.00205                             
        ph.ecog                                                          0.756       
        - 0          9/27         28/36        0.54         0.831                    
                     (74.24)      (94.28)      (0.25,                                
                                               1.15);                                
                                               p=0.112                               
        - 1          28/42        54/71        0.53         0.226                    
                     (93.59)      (94.82)      (0.33,                                
                                               0.85);                                
                                               p=0.0076                              
        - 2          16/21        28/29        0.70         0.0731                   
                     (100.00)     (100.00)     (0.37,                                
                                               1.30);                                
                                               p=0.254                               
      ───────────────────────────────────────────────────────────────────────────────
      
      Column names: V1, V2, V3, V4, V5, V6

