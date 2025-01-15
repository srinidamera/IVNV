/*
* @description    Zip Response Wrapper
* @group          HUD AMI Integration
*/
public with sharing class HudAmiCountyZipResponse {
	public Data data;
    
    public class Results {
        public String geoid;
        public Double res_ratio;
        public Double bus_ratio;
        public Double oth_ratio;
        public Double tot_ratio;
    }
    
    public class Data {
        public String year;
        public String quarter;
        public String input;
        public String crosswalk_type;
        public List<Results> results;
    }
}