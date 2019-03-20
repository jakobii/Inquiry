
[array]$global:locations = @( #[fix] confirm this location information
    @{
        id      = "0" #work_loc1 , #check_sort1
        name    = "Warehouse"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "00004381-66CF-44E0-88E6-2568B9F5C271"
        }
    }
    @{
        id      = "1"
        name    = "Burnett Elementary School"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = 'FBE3CA76-ADA5-4A94-8382-80D9BB691DFD'
            staff   = 'E5FDBF19-CA2E-4F74-92B9-407E7614B068'
        }
    }
    @{
        id         = "2"
        name       = "El Toro Elementary School"
        url        = 'http://eltoro.mhusd.org/'
        phone      = '(408) 201-6380'
        address    = '455 E Main Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 2
        ou         = @{
            default = "EE274216-408F-4DFD-81A0-A75B165DCB72"
            teacher = 'D5903802-5ECD-47EA-8BD2-A195B3363884'
            staff   = 'BF91679F-5CC6-42B4-B7AB-649674C0E571'
        }
    }
    @{
        id      = "3"
        name    = "Encinal Elementary School"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = ''
        }
    }
    @{
        id      = "4"
        name    = "Gwinn Elementary School"
        url     = 'http://paradise.mhusd.org/'
        phone   = '(408) 201-6460'
        address = '1400 La Crosse Dr'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 10
        ou      = @{
            default = "D69E5957-3B90-4CCE-87F7-02FBF0BD05C6"
            teacher = '9FA79C2F-CC06-40F4-99F3-043783FCFEEE'
            staff   = 'B4EC1AE5-9046-4D46-A579-B864B9AB9E15'
        }
    }
    @{
        id         = "5"
        name       = "Jackson Elementary School"
        url        = 'http://jackson.mhusd.org/'
        phone      = '(408) 201-6400'
        address    = '2700 Fountain Oaks Dr'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 15
        ou         = @{
            default = "6945C672-E58B-42AA-8AEA-0A5E30771FD1"
            teacher = 'D4195B52-00B1-4617-A7C6-C8D777DEFD69'
            staff   = '777FD3D3-0C83-4871-A770-10A4D00A0E44'
        }
    }
    @{
        id         = "6"
        name       = "Los Paseos Elementary School"
        url        = 'http://lospaseos.mhusd.org/'
        phone      = '(408) 201-6420'
        address    = '121 Avenida Grande'
        city       = 'San Jose'
        zip        = '95139'
        SchoolType = 'Elementary'
        school     = 6
        ou         = @{
            default = "79F0EAC8-B745-4C62-8F22-E0A1F6F43FC3"
            teacher = "4EEB4B28-2A29-4131-B9B1-9EF54649CC99"
            staff   = "F7C19B8C-35D2-414E-B569-DBA33D547C73"
        }
    }
    @{
        id         = "8"
        name       = "Nordstrom Elementary School"
        url        = 'http://nordstrom.mhusd.org/'
        phone      = '(408) 201-6440'
        address    = '1425 E Dunne Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 8
        ou         = @{
            default = "B5E8E3E6-540D-4F4B-B142-C223E55952D5"
            teacher = '0AD792C8-1BD4-45E8-84CB-94EBD9849884'
            staff   = '14C06F6C-1ADF-43A7-BB24-CDF10CFC35D2'
        }
    }
    @{
        id         = "9"
        name       = "Paradise Valley Elementary School"
        url        = 'http://paradise.mhusd.org/'
        phone      = '(408) 201-6460'
        address    = '1400 La Crosse Dr'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 9

        ou         = @{
            default = "78449B5C-ECDD-40DA-8851-B645B647CB7B"
            teacher = 'ED942772-7DC4-42B6-B527-DB9DFB5C5E0C'
            staff   = '6F5622F1-97C4-4BCA-B885-0C133E7EBCA3'
        }
    }
    @{
        id         = "10"
        name       = "San Martin Elementary School"
        url        = 'http://smg.mhusd.org/'
        phone      = '(408) 201-6460'
        address    = '13745 Llagas Ave'
        city       = 'San Martin'
        zip        = '95046'
        SchoolType = 'Elementary'
        school     = 10
        ou         = @{
            default = "D69E5957-3B90-4CCE-87F7-02FBF0BD05C6"
            teacher = '9FA79C2F-CC06-40F4-99F3-043783FCFEEE'
            staff   = 'B4EC1AE5-9046-4D46-A579-B864B9AB9E15'
        }
    }
    @{
        id         = "11"
        name       = "Walsh Elementary School"
        url        = 'http://pawalsh.mhusd.org/'
        phone      = '(408) 201-6500'
        address    = '353 W Main Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 11
        ou         = @{
            default = "4FEFC139-C07A-47E6-8BCD-529A47248CC8"
            teacher = 'FBE3CA76-ADA5-4A94-8382-80D9BB691DFD'
            staff   = 'E5FDBF19-CA2E-4F74-92B9-407E7614B068'
        }
    }
    @{
        id         = "12"
        name       = "Barrett Elementary"
        url        = 'http://barrett.mhusd.org/'
        phone      = '(408) 201-6340'
        address    = '895 Barrett Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 12
        ou         = @{
            default = "03783A35-2FD6-4CD0-B321-368480E7D270"
            teacher = '01A3B12F-F434-4FE9-8DEB-F79D5B5428DF'
            staff   = '6B7A3794-5549-48A6-B3C5-3EF3352EF0DB'
        }
    }
    @{
        id         = "20"
        name       = "Britton Middle School"
        url        = 'http://britton.mhusd.org/'
        phone      = '(408) 201-6160'
        address    = '80 W Central Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Secondary'
        school     = 20
        ou         = @{
            default = "55F46FC7-F240-4D1F-9EF9-9A17603FF243"
            teacher = 'D4675954-593A-4163-A2C0-F17FABEDD497'
            staff   = '0DE03A7F-2F7F-4898-AC19-4431B4EE80C9'
        }
    }
    @{
        id         = "21"
        name       = "Martin Murphy Middle School"
        url        = 'http://martinmurphy.mhusd.org/'
        phone      = '(408) 201-6260'
        address    = '141 Avenida Espana'
        city       = 'San Jose'
        zip        = '95139'
        SchoolType = 'Secondary'
        school     = 21
        ou         = @{
            default = "2A4316E2-DBC8-4E17-AC93-92F7BF6CCA3D"
            teacher = 'F8ADC700-D7D7-41F7-BFDC-3119B366D12C'
            staff   = '5B5BA1E0-1BF0-47C8-882D-EEE9F9E70BDC'
        }
    }
    @{
        id         = "30"
        name       = "Central High School"
        url        = 'http://central.mhusd.org/'
        phone      = '(408) 201-6300'
        address    = '85 Tilton Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Secondary'
        school     = 30
        ou         = @{
            default = "1F75E829-2248-4F41-88A0-5540442CC799"
            teacher = 'E02353E1-1921-4E7F-A14B-25A7BF3F4147'
            staff   = '806B92FC-CEE9-4778-B273-A1C21FF4DB1D'
        }
    }
    @{
        id         = "31"
        name       = "Live Oak High School"
        url        = 'http://liveoak.mhusd.org/'
        phone      = '(408) 201-6100'
        address    = '1505 E Main Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Secondary'
        school     = 31
        ou         = @{
            default = "593F2335-97AC-4767-B457-DE1C7415CBDA"
            teacher = '23DF04B8-4962-4E20-85D1-C1377514649B'
            staff   = '2F9DCF9F-4C47-45A6-9D8C-54D90831EC6F'
        }
    }
    @{
        id         = "34"
        name       = "Ann Sobrato High School"
        url        = 'http://sobrato.mhusd.org/'
        phone      = '(408) 201-6200'
        address    = '401 Burnett Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Secondary'
        school     = 32
        ou         = @{
            default = "38FBB92A-B9AC-42EC-8915-4A9AFCE6A729"
            teacher = 'EDC500B7-C0E3-4B49-B3E4-AFCFC51749EF'
            staff   = '5B1A7131-E1FD-4908-9C45-80FDEDA84459'
        }
    }
    @{
        id         = "40"
        name       = "Community Adult School"
        url        = 'http://adultschool.mhusd.org/'
        phone      = '(408) 201-6520'
        address    = '17960 Monterey Rd'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Secondary'
        school     = 0
        ou         = @{
            default = "6546CD3E-262F-4F7E-8913-BCE66001BDC2"
            teacher = '4A158B3B-C498-4F23-BF39-7BB248459944'
            staff   = 'E576D0C2-6B31-4BC8-A390-5DA7FB4BEA83'
        }
    }
    @{
        id      = "70"
        name    = "District Office Staff"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8c8e0cc3-6b14-4df7-a02f-06f7d065008b"
            teacher = '4f6d94fe-cb0b-425f-82b6-f49e7241c807'
            staff   = '8c8e0cc3-6b14-4df7-a02f-06f7d065008b'
        }
    }
    @{
        id      = "71"
        name    = "Special Services"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = 'E576D0C2-6B31-4BC8-A390-5DA7FB4BEA83'
            staff   = ''
        }
    }
    @{
        id      = "72"
        name    = "Special Education"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "6546CD3E-262F-4F7E-8913-BCE66001BDC2"
            teacher = ''
            staff   = '655CC374-439E-49F7-BACC-84AE10EDE2D2'
        }
    }
    @{
        id      = "77"
        name    = "Migrant Education"
        url     = 'http://adultschool.mhusd.org/'
        phone   = '(408) 201-6520'
        address = '17960 Monterey Rd'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = 'E576D0C2-6B31-4BC8-A390-5DA7FB4BEA83'
        }
    }
    @{
        id      = "80"
        name    = "Maintenance/Operations"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "6546CD3E-262F-4F7E-8913-BCE66001BDC2"
            teacher = ''
            staff   = 'ED12150A-5C5A-415F-8F64-3303F2368878'
        }
    }
    @{
        id      = "81"
        name    = "Transportation"
        url     = 'http://www.mhusd.org/business-services/transportation/'
        phone   = '(408) 201-6320'
        address = '105 Edes St'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8F948968-A92B-4AE0-88D2-C8CCE4B216D4"
            staff   = 'E8F309B4-0172-4444-A4FC-4B730FB891B0'
        }
    }
    @{
        id      = "85"
        name    = "Warehouse"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "00004381-66CF-44E0-88E6-2568B9F5C271"
        }
    }
    @{
        id      = "88"
        name    = "Charter School"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
        }
    }
    @{
        id      = "92"
        name    = "Warehouse"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            # THIS TENDS TO BE A GENERIC PLACE WHERE
            # EMPLOYEES GET DUMPED HERE A LOT
            default = "00004381-66CF-44E0-88E6-2568B9F5C271"
        }
    }
    @{
        id      = "93"
        name    = "Maintenance"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "ED12150A-5C5A-415F-8F64-3303F2368878"
        }
    }
    @{
        id      = "94"
        name    = "Sobrato Kitchen"
        url     = 'http://sobrato.mhusd.org/'
        phone   = '(408) 201-6200'
        address = '401 Burnett Ave'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 31
        ou      = @{
            default = "38FBB92A-B9AC-42EC-8915-4A9AFCE6A729"
        }
    }
    @{
        id      = "95"
        name    = "Live Oak Kitchen"
        url     = 'http://liveoak.mhusd.org/'
        phone   = '(408) 201-6100'
        address = '1505 E Main Ave'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 31
        ou      = @{
            default = "7df280b0-8146-43bc-bb38-d9301eb96b0b"
        }
    }
    @{
        id      = "96"
        name    = "Operations"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            staff   = 'ED12150A-5C5A-415F-8F64-3303F2368878'
        }
    }
    @{
        id      = "99"
        name    = "Substitutes"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
        }
    }
    @{
        id      = "8400"
        name    = "Superintendent"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = 'EF1B2D39-59E0-4B10-B6C8-6487AB9CDC62'
        }
    }
    @{
        id      = "8401"
        name    = "Burnett Elementary School"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
        }
    }
    @{
        id         = "8402"
        name       = "El Toro"
        url        = 'http://eltoro.mhusd.org/'
        phone      = '(408) 201-6380'
        address    = '455 E Main Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 2

        ou         = @{
            default = "EE274216-408F-4DFD-81A0-A75B165DCB72"
            teacher = 'D5903802-5ECD-47EA-8BD2-A195B3363884'
            staff   = 'BF91679F-5CC6-42B4-B7AB-649674C0E571'
        }
    }
    @{
        id      = "8403"
        name    = "Encinal"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
        }
    }
    @{
        id         = "8405"
        name       = "Jackson"
        url        = 'http://jackson.mhusd.org/'
        phone      = '(408) 201-6400'
        address    = '2700 Fountain Oaks Dr'
        city       = 'Morgan Hill'
        zip        = '95037'
        school     = 15
        SchoolType = 'Elementary'
        ou         = @{
            default = "6945C672-E58B-42AA-8AEA-0A5E30771FD1"
            teacher = 'D4195B52-00B1-4617-A7C6-C8D777DEFD69'
            staff   = '777FD3D3-0C83-4871-A770-10A4D00A0E44'
        }
    }
    @{
        id         = "8406"
        name       = "Los Paseos"
        url        = 'http://lospaseos.mhusd.org/'
        phone      = '(408) 201-6420'
        address    = '121 Avenida Grande'
        city       = 'San Jose'
        zip        = '95139'
        SchoolType = 'Elementary'
        school     = 6
        ou         = @{
            default = "79F0EAC8-B745-4C62-8F22-E0A1F6F43FC3"
            teacher = '4EEB4B28-2A29-4131-B9B1-9EF54649CC99'
            staff   = 'F7C19B8C-35D2-414E-B569-DBA33D547C73'
        }
    }
    @{
        id      = "8407"
        name    = "Machado"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
        }
    }
    @{
        id         = "8408"
        name       = "Nordstrom"
        url        = 'http://nordstrom.mhusd.org/'
        phone      = '(408) 201-6440'
        address    = '1425 E Dunne Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 8
        ou         = @{
            default = "B5E8E3E6-540D-4F4B-B142-C223E55952D5"
            teacher = '0AD792C8-1BD4-45E8-84CB-94EBD9849884'
            staff   = '14C06F6C-1ADF-43A7-BB24-CDF10CFC35D2'
        }
    }
    @{
        id         = "8409"
        name       = "Paradise"
        url        = 'http://paradise.mhusd.org/'
        phone      = '(408) 201-6460'
        address    = '1400 La Crosse Dr'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 9
        ou         = @{
            default = "78449B5C-ECDD-40DA-8851-B645B647CB7B"
            teacher = 'ED942772-7DC4-42B6-B527-DB9DFB5C5E0C'
            staff   = '6F5622F1-97C4-4BCA-B885-0C133E7EBCA3'
        }
    }
    @{
        id         = "8410"
        name       = "San Martin/Gwinn"
        url        = 'http://paradise.mhusd.org/'
        phone      = '(408) 201-6460'
        address    = '1400 La Crosse Dr'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 10
        ou         = @{
            default = "D69E5957-3B90-4CCE-87F7-02FBF0BD05C6"
            teacher = '9FA79C2F-CC06-40F4-99F3-043783FCFEEE'
            staff   = 'B4EC1AE5-9046-4D46-A579-B864B9AB9E15'
        }
    }
    @{
        id         = "8411"
        name       = "Walsh"
        url        = 'http://pawalsh.mhusd.org/'
        phone      = '(408) 201-6500'
        address    = '353 W Main Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 12
        ou         = @{
            default = "4FEFC139-C07A-47E6-8BCD-529A47248CC8"
            teacher = 'FBE3CA76-ADA5-4A94-8382-80D9BB691DFD'
            staff   = 'E5FDBF19-CA2E-4F74-92B9-407E7614B068'
        }
    }
    @{
        id         = "8412"
        name       = "Barrett"
        url        = 'http://barrett.mhusd.org/'
        phone      = '(408) 201-6340'
        address    = '895 Barrett Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Elementary'
        school     = 0
        ou         = @{
            default = "03783A35-2FD6-4CD0-B321-368480E7D270"
            teacher = '01A3B12F-F434-4FE9-8DEB-F79D5B5428DF'
            staff   = '6B7A3794-5549-48A6-B3C5-3EF3352EF0DB'
        }
    }
    @{
        id      = "8415"
        name    = "Elementary Library"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
        }
    }
    @{
        id         = "8420"
        name       = "Britton"
        url        = 'http://britton.mhusd.org/'
        phone      = '(408) 201-6160'
        address    = '80 W Central Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Secondary'
        school     = 20
        ou         = @{
            default = "55F46FC7-F240-4D1F-9EF9-9A17603FF243"
            teacher = 'D4675954-593A-4163-A2C0-F17FABEDD497'
            staff   = '0DE03A7F-2F7F-4898-AC19-4431B4EE80C9'
        }
    }
    @{
        id         = "8421"
        name       = "Murphy"
        url        = 'http://martinmurphy.mhusd.org/'
        phone      = '(408) 201-6260'
        address    = '141 Avenida Espana'
        city       = 'San Jose'
        zip        = '95139'
        SchoolType = 'Secondary'
        school     = 21
        ou         = @{
            default = "2A4316E2-DBC8-4E17-AC93-92F7BF6CCA3D"
            teacher = 'F8ADC700-D7D7-41F7-BFDC-3119B366D12C'
            staff   = '5B5BA1E0-1BF0-47C8-882D-EEE9F9E70BDC'
        }
    }
    @{
        id         = "8430"
        name       = "Central"
        url        = 'http://central.mhusd.org/'
        phone      = '(408) 201-6300'
        address    = '85 Tilton Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Secondary'
        school     = 30
        ou         = @{
            default = "1F75E829-2248-4F41-88A0-5540442CC799"
            teacher = 'E02353E1-1921-4E7F-A14B-25A7BF3F4147'
            staff   = '806B92FC-CEE9-4778-B273-A1C21FF4DB1D'
        }
    }
    @{
        id         = "8431"
        name       = "Live Oak"
        url        = 'http://liveoak.mhusd.org/'
        phone      = '(408) 201-6100'
        address    = '1505 E Main Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Secondary'
        school     = 31
        ou         = @{
            default = "593F2335-97AC-4767-B457-DE1C7415CBDA"
            teacher = '23DF04B8-4962-4E20-85D1-C1377514649B'
            staff   = '2F9DCF9F-4C47-45A6-9D8C-54D90831EC6F'
        }
    }
    @{
        id         = "8432"
        name       = "Live Oak Library"
        url        = 'http://liveoak.mhusd.org/'
        phone      = '(408) 201-6100'
        address    = '1505 E Main Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Secondary'
        school     = 31
        ou         = @{
            default = "593F2335-97AC-4767-B457-DE1C7415CBDA"
            teacher = '23DF04B8-4962-4E20-85D1-C1377514649B'
            staff   = '2F9DCF9F-4C47-45A6-9D8C-54D90831EC6F'
        }
    }
    @{
        id         = "8434"
        name       = "Ann Sobrato High School"
        url        = 'http://sobrato.mhusd.org/'
        phone      = '(408) 201-6200'
        address    = '401 Burnett Ave'
        city       = 'Morgan Hill'
        zip        = '95037'
        SchoolType = 'Secondary'
        school     = 32
        ou         = @{
            default = "38FBB92A-B9AC-42EC-8915-4A9AFCE6A729"
            teacher = 'EDC500B7-C0E3-4B49-B3E4-AFCFC51749EF'
            staff   = '5B1A7131-E1FD-4908-9C45-80FDEDA84459'
        }
    }
    @{
        id      = "8440"
        name    = "Cas"
        url     = 'http://adultschool.mhusd.org/'
        phone   = '(408) 201-6520'
        address = '17960 Monterey Rd'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "6546CD3E-262F-4F7E-8913-BCE66001BDC2"
            teacher = '4A158B3B-C498-4F23-BF39-7BB248459944'
            staff   = 'E576D0C2-6B31-4BC8-A390-5DA7FB4BEA83'
        }
    }
    @{
        id      = "8450"
        name    = "Saint Catherine's"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
        }
    }
    @{
        id      = "8471"
        name    = "Business Services"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = 'F0EE1974-3A7C-47BA-AA66-D5D581EEE9D6'
            staff   = 'F0EE1974-3A7C-47BA-AA66-D5D581EEE9D6'
        }
    }
    @{
        id      = "8472"
        name    = "Educational Services"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = 'DB7502D8-F440-486F-B6F3-516C91F98860'
            staff   = 'DB7502D8-F440-486F-B6F3-516C91F98860'
        }
    }
    @{
        id      = "8473"
        name    = "Human Resources"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = '93B5B873-B00E-4308-B838-A9609D86E473'
        }
    }
    @{
        id      = "8474"
        name    = "Special Services"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = '49EA81F7-26A9-448B-A9C8-92021DD522B9'
        }
    }
    @{
        id      = "8475"
        name    = "Health Services"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = ''
        }
    }
    @{
        id      = "8476"
        name    = "Student Services"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = ''
        }
    }
    @{
        id      = "8477"
        name    = "Technology"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = '7556BA03-09DE-4C88-92ED-67EAD3A13D4F'
        }
    }
    @{
        id      = "8479"
        name    = "Purchasing Department"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = 'F0EE1974-3A7C-47BA-AA66-D5D581EEE9D6'
        }
    }
    @{
        id      = "8481"
        name    = "Maintenance"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = 'ED12150A-5C5A-415F-8F64-3303F2368878'
        }
    }
    @{
        id      = "8482"
        name    = "Transportation"
        url     = 'http://www.mhusd.org/business-services/transportation/'
        phone   = '(408) 201-6320'
        address = '105 Edes St'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8F948968-A92B-4AE0-88D2-C8CCE4B216D4"
            teacher = ''
            staff   = 'E8F309B4-0172-4444-A4FC-4B730FB891B0'
        }
    }
    @{
        id      = "8483"
        name    = "Grounds/Custodial"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = 'ED12150A-5C5A-415F-8F64-3303F2368878'
        }
    }
    @{
        id      = "8484"
        name    = "Facilities"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = 'ED12150A-5C5A-415F-8F64-3303F2368878'
        }
    }
    @{
        id      = "8486"
        name    = "Print Shop"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = 'ED12150A-5C5A-415F-8F64-3303F2368878'
        }
    }
    @{
        id      = "8487"
        name    = "Construction/Modernization"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = 'ED12150A-5C5A-415F-8F64-3303F2368878'
        }
    }
    @{
        id      = "8490"
        name    = "Food Service Warehouse"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = '7DF280B0-8146-43BC-BB38-D9301EB96B0B'
        }
    }
    @{
        id      = "8495"
        name    = "District Kitchen"
        url     = 'http://mhusd.org/'
        phone   = '(408) 201-6000'
        address = '15600 Concord Cir'
        city    = 'Morgan Hill'
        zip     = '95037'
        school  = 0
        ou      = @{
            default = "8C8E0CC3-6B14-4DF7-A02F-06F7D065008B"
            teacher = ''
            staff   = '7DF280B0-8146-43BC-BB38-D9301EB96B0B'
        }
    }
)

$loc = 0..$locations.Count
foreach ($location in $locations) {
    $location.id + "," + $location.name
}
