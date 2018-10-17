<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/"
    
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> August 14, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> Andrea</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="mets:mets" xmlns:mets="http://www.loc.gov/METS/">
        <mods:mods xmlns="http://www.loc.gov/mods/v3" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:etd="http://www.ndltd.org/standards/metadata/etdms/1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.5" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
            <mods:titleInfo>
            <!-- map  dc:title to mods:title -->
                 <mods:title>
                      <xsl:value-of select="mets:dmdSec[1]/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:title" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/"/>
                 </mods:title>
            </mods:titleInfo>
            <!-- if dc:creator exists, map every dc:creator name to mods:namePart and creator for mods:roleTerm  -->
            <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:creator!=''">
                 <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:creator[text() != '']">
                      <mods:name>
                           <mods:namePart>
                                <xsl:value-of select="."/>
                           </mods:namePart>
                           <mods:role>
                                <mods:roleTerm authority="marcrelator" type="text">creator</mods:roleTerm>
                           </mods:role>
                      </mods:name>
                 </xsl:for-each>
            </xsl:if>    
            <!-- if dc:contributor exists, map every dc:contributor name to mods:namePart and contributor for mods:roleTerm -->         
            <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:contributor!=''">           
                 <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:contributor[text() != '']">
                      <mods:name>
                           <mods:namePart>
                                <xsl:value-of select="."/>
                           </mods:namePart>
                           <mods:role>
                                <mods:roleTerm authority="marcrelator" type="text">contributor</mods:roleTerm>
                           </mods:role>
                      </mods:name>
                 </xsl:for-each>
            </xsl:if>
            <!-- if dc:type exists map the values to the corresponding values for mods:typeofresource -->
            <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:type!=''">
                 <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:type[text() != '']">
                      <xsl:if test=".='Electronic thesis'">
                           <mods:typeOfResource>text</mods:typeOfResource>
                      </xsl:if>
                      <xsl:if test=".='Image'">
                           <mods:typeOfResource>still image</mods:typeOfResource>
                      </xsl:if>
                      <xsl:if test=".='Sound'">
                           <mods:typeOfResource>sound recording</mods:typeOfResource>
                      </xsl:if>
                      <xsl:if test=".='Text'">
                           <mods:typeOfResource>text</mods:typeOfResource>
                      </xsl:if>
                      <xsl:if test="starts-with(., 'Moving')">
                           <mods:typeOfResource>moving image</mods:typeOfResource>
                      </xsl:if>
                      <xsl:if test="starts-with(., 'Still')">
                           <mods:typeOfResource>still image</mods:typeOfResource>
                      </xsl:if>
                 </xsl:for-each>
            </xsl:if>
           <!-- if dc:type exists map the values to the corresponding values for mods:genre using the MARC Genre Term List -->
           <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:type!=''">
               <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:type[text() != '']">
                   <xsl:if test=".='College student newspapers and periodicals'">
                       <mods:genre authority="marcgt">newspaper</mods:genre>
                   </xsl:if>
                   <xsl:if test=".='Electronic thesis'">
                       <mods:genre authority="marcgt">thesis</mods:genre>
                   </xsl:if>
               </xsl:for-each>
           </xsl:if>
           <mods:physicalDescription>
            <!-- sets mods:reformattingQuality value to access and these are all for access copies going into islandora -->    
                <mods:reformattingQuality>access</mods:reformattingQuality>
                <!-- if the value for dc:format is a mimetype, maps the value dc:format to mods:internetMediaType if the value is not a mimetype, maps the dc:format to mods:form -->
                <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:format!=''">
                     <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:format[text() != '']">
                          <xsl:choose>
                             <xsl:when test="contains(., 'ideo/')">
                                  <mods:internetMediaType>
                                       <xsl:value-of select="."/>
                                  </mods:internetMediaType>
                             </xsl:when>
                             <xsl:when test="contains(., 'ext/')">
                                  <mods:internetMediaType>
                                       <xsl:value-of select="."/>
                                  </mods:internetMediaType>
                             </xsl:when>
                             <xsl:when test="contains(., 'mage/')">
                                  <mods:internetMediaType>
                                       <xsl:value-of select="."/>
                                  </mods:internetMediaType>
                             </xsl:when>
                             <xsl:when test="contains(., 'udio/')">
                                  <mods:internetMediaType>
                                       <xsl:value-of select="."/>
                                  </mods:internetMediaType>
                             </xsl:when>
                             <xsl:when test="contains(., 'pplication/')">
                                 <mods:internetMediaType>
                                      <xsl:value-of select="."/>
                                 </mods:internetMediaType>
                             </xsl:when> 
                             <xsl:otherwise>
                                  <mods:form>
                                       <xsl:value-of select="."/>
                                  </mods:form>
                             </xsl:otherwise>
                          </xsl:choose>
                     </xsl:for-each>
                </xsl:if>
                <!-- if the custom field image_specifications exists map the value to notes element in mods:physicalDescription -->
                <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/image_specifications!=''">
                     <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/image_specifications[text() != '']">
                          <note>
                              <xsl:value-of select="."/>
                          </note>
                     </xsl:for-each>        
                </xsl:if>      
            </mods:physicalDescription>
           <!-- if dc:description exists, map each value to the top element mods:note -->
           <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:description!=''">
                <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:description[text() != '']">
                     <mods:note>
                          <xsl:value-of select="."/>
                     </mods:note>
                </xsl:for-each>
           </xsl:if>
           <!-- if dcterms:abstract exists, map each value to mods:abstract -->
           <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dcterms:abstract!=''">
                <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dcterms:abstract[text() != '']">
                     <mods:abstract>
                          <xsl:value-of select="."/>
                     </mods:abstract>    
                </xsl:for-each>
           </xsl:if>
           <!-- if dc:subject exists map each value to mods:topic in the mods:subject element -->
           <xsl:if test="mets:dmdSec[1]/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:subject!=''">
                <xsl:for-each select="mets:dmdSec[1]/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:subject[text() != '']">
                     <mods:subject>
                          <mods:topic>
                               <xsl:value-of select="."/>
                          </mods:topic>
                     </mods:subject>
                </xsl:for-each>
           </xsl:if>
           <!-- if dc:coverage exists map each value to mods:geographic -->
           <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:coverage!=''">
               <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:coverage[text() != '']">
                    <mods:subject>
                         <mods:geographic>
                             <xsl:value-of select="."/>
                         </mods:geographic>
                    </mods:subject>
               </xsl:for-each>
           </xsl:if>
           <!-- if dc:identifier exists map value to mods:identifier with the type local -->
           <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:identifier!=''">
               <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:identifier[text() != '']">
                    <mods:identifier type="local">
                         <xsl:value-of select="."/>
                    </mods:identifier>
               </xsl:for-each>
           </xsl:if>
           <mods:originInfo>
               <!-- if the field dc:created exists map value to  mods:originInfo subelement dateIssued -->
               <xsl:if test="mets:dmdSec[1]/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:created!=''">
                   <xsl:for-each select="mets:dmdSec[1]/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:created[text() != '']">
                        <mods:dateIssued>
                             <xsl:value-of select="."/>
                        </mods:dateIssued>
                   </xsl:for-each>        
               </xsl:if> 
               <!-- if dc:date exists map value to mods:originInfo subelement dateIssued -->
               <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:date!=''">
                   <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:date[text() != '']">
                        <mods:dateIssued>
                             <xsl:value-of select="."/>
                        </mods:dateIssued>
                   </xsl:for-each>        
               </xsl:if>    
               <!-- use dc:publisher values for mods:originInfo subelements dateIssued and publisher -->
               <mods:publisher>
                    <xsl:value-of select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:publisher" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/"/>
               </mods:publisher>
           </mods:originInfo>
           <!-- if the value for dc:typeis Electronic Thesis, map the values for the fields dcterms:degree.name and dcterms:degree.discipline to mods:extension subelement edt:degree to edt:level and etd:discipline  -->
           <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:type='Electronic thesis'">
               <mods:extension>
                    <etd:degree>
                        <etd:level>
                             <xsl:value-of select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dcterms:degree.name"/>
                        </etd:level>
                        <etd:discipline>
                             <xsl:value-of select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dcterms:degree.discipline"/>
                        </etd:discipline>
                    </etd:degree>
               </mods:extension>
           </xsl:if>
           <!-- if dc:terms accessRights exists, map values to mods:accessCondition with the type restrictions on access  --> 
           <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dcterms:accessRights!=''">
               <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dcterms:accessRights[text() != '']">
                    <mods:accessCondition type="restrictions on access">
                        <xsl:value-of select="."/>
                    </mods:accessCondition>
               </xsl:for-each>
           </xsl:if>
           <!-- if dc:rights exits, map values to mods:accessCondition with the type use and reproduction -->
           <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:rights!=''">
               <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:rights[text() != '']">
                    <mods:accessCondition type="use and reproduction">
                        <xsl:value-of select="."/>
                    </mods:accessCondition>
               </xsl:for-each>        
           </xsl:if>
           <!-- map the archivematica uuid to mods:relatedItem with the type original and the subelement title -->
           <mods:relatedItem type="original">
               <mods:titleInfo>
                    <mods:title>
                        <xsl:value-of select="mets:structMap[1]/mets:div/@LABEL"/>
                    </mods:title>
               </mods:titleInfo>
           </mods:relatedItem>
           <!-- map the dc:relation value to mods:relatedItem with the type host and the subelement title -->
           <mods:relatedItem type="host">
               <mods:titleInfo>
                    <mods:title>
                        <xsl:value-of select="mets:dmdSec/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:relation" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/"/>
                    </mods:title>
               </mods:titleInfo>
               <!-- if the field physical location exists, map the value to mods:relatedItem with the type host and the subelement physical location -->
               <xsl:if test="mets:dmdSec/mets:mdWrap/mets:xmlData/physical_location!=''">
                   <xsl:for-each select="mets:dmdSec/mets:mdWrap/mets:xmlData/physical_location[text() != '']">
                        <mods:location>
                             <mods:physicalLocation>
                                 <xsl:value-of select="."/>
                             </mods:physicalLocation>
                        </mods:location>
                   </xsl:for-each>
               </xsl:if>
           </mods:relatedItem>
           <!-- if the field dcterms:source exists map value to mods:relatedItem with the type otherFormat subelement title -->
           <xsl:if test="mets:dmdSec[1]/mets:mdWrap/mets:xmlData/dcterms:dublincore/dcterms:source!=''">
               <xsl:for-each select="mets:dmdSec[1]/mets:mdWrap/mets:xmlData/dcterms:dublincore/dcterms:source[text() != '']">
                    <mods:relatedItem type="otherFormat">
                         <mods:titleInfo>
                              <mods:title>
                                  <xsl:value-of select="."/>
                              </mods:title>
                         </mods:titleInfo>
                    </mods:relatedItem>
               </xsl:for-each>
           </xsl:if>
           <!-- if the field dc:source exists map value to mods:relatedItem with the type otherFormat subelement title 
           <xsl:if test="mets:dmdSec[1]/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:source!=''">
               <xsl:for-each select="mets:dmdSec[1]/mets:mdWrap/mets:xmlData/dcterms:dublincore/dc:source[text() != '']">
                   <mods:relatedItem type="otherFormat">
                       <mods:titleInfo>
                           <mods:title>
                               <xsl:value-of select="."/>
                           </mods:title>
                       </mods:titleInfo>
                   </mods:relatedItem>
               </xsl:for-each>
           </xsl:if>--> 
         </mods:mods>
       </xsl:template>
        <xsl:template match="/">
        <xsl:apply-templates/>
     </xsl:template>
</xsl:stylesheet>