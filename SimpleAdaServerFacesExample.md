## Root view ##

The ASF facelet view should contain at the root of the component tree a `UIView` element represented by the `f:view` XML element.  The main facelet file could therefore start with the following tag:

```
<f:view contentType="text/html"
        xmlns:ui="http://java.sun.com/jsf/facelets"
        xmlns:f="http://java.sun.com/jsf/core"
        xmlns:c="http://java.sun.com/jstl/core"
	xmlns:u="http://code.google.com/p/ada-asf/util"
        xmlns:h="http://java.sun.com/jsf/html">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <link media="screen" type="text/css" rel="stylesheet" href="#{contextPath}/themes/main.css"/>
    <title>Volume Cylinder</title>
</head>
<body>
   ...
</body>
</html>
</f:view>
```

The `contentType` attribute allows to control the HTTP Content-Type header that will be returned in the response.  The `xmlns` attributes indicates the namespaces that are used by other ASF components in the view.

When ASF restores the view associated with the facelet file, it will create a `UIView` component that will hold the complete view.  The `f:view` node can hold HTML element as well as specific ASF or application components.

## Form Definition ##

A form is represented by the `h:form` entity which corresponds to the HTML form element.  Within the form, an input text field is represented by `h:input`. The input field specified a value binding to link the input field to a bean attribute.  When the view is rendered, the value is read from the bean (by calling the `Get_Value` function of the object).  When the form is submitted, the submitted value is saved on the bean (by calling the `Set_Value` procedure).

```
<h:form id='compute'>
  <table>
    <tr><td>Height</td>
    <td>
      <h:input id='height' size='10' value='#{compute.height}'>
        <f:converter converterId="float"/>
      </h:input>
    </td></tr>
    <tr><td>Radius</td>
    <td>
      <h:input id='radius' size='10' value='#{compute.radius}'>
        <f:converter converterId="float"/>
      </h:input>
    </td></tr>
    <tr><td></td>
    <td>
       <h:commandButton id='run' value='Compute' action="#{compute.run}"/>
    </td></tr>
  </table>
</h:form>
```

The form can also integrate command buttons represented by `h:commandButton`.  An action attribute represents the procedure to invoke on the bean when the form is submitted.