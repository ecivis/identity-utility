<cfsetting showdebugoutput="false" enablecfoutputonly="true"/>

<cfparam name="url.reporter" default="simple"/>
<cfparam name="url.directory" default="tests.specs"/>
<cfparam name="url.recurse" default="true" type="boolean"/>
<cfparam name="url.bundles" default=""/>
<cfparam name="url.labels" default=""/>

<cfinclude template="/testbox/system/runners/HTMLRunner.cfm"/>