

XPath: `/*[local-name()='PartSync' and namespace-uri()='http://www.consafelogistics.com/astro/project']/*[local-name()='DataArea' and namespace-uri()='http://www.consafelogistics.com/astro/project']/*[local-name()='Part' and namespace-uri()='http://www.consafelogistics.com/astro/project']/*[local-name()='PartId' and namespace-uri()='http://www.consafelogistics.com/astro/project']/*[local-name()='Id' and namespace-uri()='http://www.consafelogistics.com/astro/project']`

Returned XSD Schema Fragments:

`<xs:element name="Id" type="PartId_0100"/>`

  `<xs:simpleType name="PartId_0100">`
    `<xs:annotation>`
      `<xs:documentation xml:lang="en">Part number.</xs:documentation>`
      `<xs:appinfo source="Astro">`
        `<appdoc:ElementDesc>`
          `<appdoc:table>l62t1</appdoc:table>`
          `<appdoc:term>partno</appdoc:term>`
        `</appdoc:ElementDesc>`
      `</xs:appinfo>`
    `</xs:annotation>`
    `<xs:restriction base="string24"/>`
  `</xs:simpleType>`