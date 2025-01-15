@isTest
public class PrettyXmlStreamWriterTest {

    testMethod static void testConstructor() {
        new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
    }
    
    testMethod static void testWriteStartANDENDElement() {
       PrettyXmlStreamWriter writer =  new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
        writer.writeStartElement('','','');
        writer.writeEndElement();
    }
    
    /*testMethod static void testWriteAttribute() {
       PrettyXmlStreamWriter writer =  new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
        writer.writeAttribute('','','','');
    }*/
    
    testMethod static void testWriteElement() {
       PrettyXmlStreamWriter writer =  new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
        writer.writeElement('','','','');
    }
    
    testMethod static void testwriteElementIfNotNull() {
       PrettyXmlStreamWriter writer =  new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
        writer.writeElementIfNotNull('','','','test');
    }
    
    testMethod static void testwriteElementWithAttribute() {
       PrettyXmlStreamWriter writer =  new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
        writer.writeElementWithAttribute('','','','test','','');
    }
    
    testMethod static void testwriteCharacters() {
       PrettyXmlStreamWriter writer =  new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
        writer.writeCharacters('test');
    }
    
    testMethod static void testwriteStartDocument() {
       PrettyXmlStreamWriter writer =  new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
        writer.writeStartDocument('UTF-8','test2');
    }
    
    testMethod static void testwriteEndDocument() {
       PrettyXmlStreamWriter writer =  new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
        writer.writeEndDocument();
    }
    
    testMethod static void testclose() {
       PrettyXmlStreamWriter writer =  new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
        writer.close();
    }
    
    testMethod static void testgetXmlString() {
       PrettyXmlStreamWriter writer =  new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
        writer.getXmlString();
    }
}