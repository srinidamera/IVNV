public class PrettyXmlStreamWriter {
    private XmlStreamWriter writer;
    private Integer indentLevel;
    private String indent;

    public PrettyXmlStreamWriter(XmlStreamWriter writer, Integer indentSize) {
        this.writer = writer;
        this.indentLevel = 0;
        this.indent = ' '.repeat(indentSize);
    }

    private void writeIndent() {
        if (indentLevel > 0) {
            writer.writeCharacters('\n' + indent.repeat(indentLevel));
        }
    }

    public void writeStartElementNoIndentNewLine(String prefix, String localName, String uri) {
        writer.writeCharacters('\n' + indent.repeat(indentLevel));
        writer.writeStartElement(prefix, localName, uri);
    }
    
    public void writeStartElementNoIndent(String prefix, String localName, String uri) {
        writer.writeStartElement(prefix, localName, uri);
    }

    public void writeEndElementNoIndent() {
        writer.writeEndElement();
    }

    public void writeStartElement(String prefix, String localName, String uri) {
        writeIndent();
        writer.writeStartElement(prefix, localName, uri);
        indentLevel++;
    }

    public void writeEndElement() {
        indentLevel--;
        writeIndent();
        writer.writeEndElement();
    }

    public void writeAttribute(String prefix, String namespaceUri, String localName, String value) {
        writer.writeAttribute(prefix, namespaceUri, localName, value);
    }

    public void writeElement(String prefix, String localName, String namespaceUri, String text) {
        writeStartElement(prefix, localName, namespaceUri);
        writer.writeCharacters(text);
        writer.writeEndElement();
        indentLevel--;
    }

    public void writeElementNoIndent(String prefix, String localName, String namespaceUri, String text) {
        writeStartElementNoIndent(prefix, localName, namespaceUri);
        writer.writeCharacters(text);
        writeEndElementNoIndent();
    }

    public void writeElementIfNotNull(String prefix, String localName, String namespaceUri, String text) {
        if(String.IsNotBlank(text)){
            writeStartElement(prefix, localName, namespaceUri);
            writer.writeCharacters(text);
            writer.writeEndElement();
            indentLevel--;
        }
    }

    public void writeElementIfNotNullNoIndent(String prefix, String localName, String namespaceUri, String text) {
        if(String.IsNotBlank(text)){
            writer.writeStartElement(prefix, localName, namespaceUri);
            writer.writeCharacters(text);
            writer.writeEndElement();
        }
    }

    public void writeElementWithAttribute(String prefix, String localName, String namespaceUri, String text, String atrName, String atrValue) {
        writeStartElement(prefix, localName, namespaceUri);
        writer.writeAttribute(null, null, atrName, atrValue);
        writer.writeCharacters(text);
        writer.writeEndElement();
        indentLevel--;
    }

    public void writeCharacters(String text) {
        writer.writeCharacters(text);
    }

    public void writeStartDocument(String arg1, String arg2) {
        writer.writeStartDocument(arg1, arg2);
    }

    public void writeEndDocument() {
        writer.writeEndDocument();
    }
    
    public void close() {
        writer.close();
    }

    public String getXmlString() {
        return writer.getXmlString();
    }
}