/*
* @description    Il Data Response Wrapper
* @group          HUD AMI Integration
*/
public class HudAmiIlDataResponse {
	public class Very_low {
        public Integer il50_p1;
        public Integer il50_p2;
        public Integer il50_p3;
        public Integer il50_p4;
        public Integer il50_p5;
        public Integer il50_p6;
        public Integer il50_p7;
        public Integer il50_p8;
    }
    
    public Data data;
    
    public class Low {
        public Integer il80_p1;
        public Integer il80_p2;
        public Integer il80_p3;
        public Integer il80_p4;
        public Integer il80_p5;
        public Integer il80_p6;
        public Integer il80_p7;
        public Integer il80_p8;
    }
    
    public class Data {
        public String county_name;
        public String counties_msa;
        public String town_name;
        public String metro_status;
        public String metro_name;
        public String area_name;
        public String year;
        public Integer median_income;
        public Very_low very_low;
        public Extremely_low extremely_low;
        public Low low;
    }
    
    public class Extremely_low {
        public Integer il30_p1;
        public Integer il30_p2;
        public Integer il30_p3;
        public Integer il30_p4;
        public Integer il30_p5;
        public Integer il30_p6;
        public Integer il30_p7;
        public Integer il30_p8;
    }
}