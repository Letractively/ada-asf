-----------------------------------------------------------------------
--  nodes-facelets -- Facelets composition nodes
--  Copyright (C) 2009, 2010, 2011, 2012, 2013 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------

--  The <b>ASF.Views.Nodes.Facelets</b> package defines some pre-defined
--  tags for composing a view.
--
--    xmlns:ui="http://java.sun.com/jsf/facelets"
--
--  The following Facelets core elements are defined:
--    <ui:include src="..."/>
--    <ui:decorate view="..."/>
--    <ui:define name="..."/>
--    <ui:insert name="..."/>
--    <ui:param name="..." value="..."/>
--    <ui:composition .../>
--
with Ada.Strings.Hash;
with ASF.Factory;
with Ada.Containers.Indefinite_Hashed_Maps;
package ASF.Views.Nodes.Facelets is

   --  Tag factory for nodes defined in this package.
   function Definition return ASF.Factory.Factory_Bindings_Access;

   --  ------------------------------
   --  Include Tag
   --  ------------------------------
   --  The <ui:include src="..."/>
   type Include_Tag_Node is new Tag_Node with private;
   type Include_Tag_Node_Access is access all Include_Tag_Node'Class;

   --  Create the Include Tag
   function Create_Include_Tag_Node (Binding    : in Binding_Access;
                                     Line       : in Line_Info;
                                     Parent     : in Tag_Node_Access;
                                     Attributes : in Tag_Attribute_Array_Access)
                                     return Tag_Node_Access;

   --  Build the component tree from the tag node and attach it as
   --  the last child of the given parent.  Calls recursively the
   --  method to create children.
   overriding
   procedure Build_Components (Node    : access Include_Tag_Node;
                               Parent  : in UIComponent_Access;
                               Context : in out Facelet_Context'Class);

   --  ------------------------------
   --  Composition Tag
   --  ------------------------------
   --  The <ui:composition template="..."/>
   type Composition_Tag_Node is new Tag_Node with private;
   type Composition_Tag_Node_Access is access all Composition_Tag_Node'Class;

   --  Create the Composition Tag
   function Create_Composition_Tag_Node (Binding    : in Binding_Access;
                                         Line       : in Line_Info;
                                         Parent     : in Tag_Node_Access;
                                         Attributes : in Tag_Attribute_Array_Access)
                                         return Tag_Node_Access;

   --  Build the component tree from the tag node and attach it as
   --  the last child of the given parent.  Calls recursively the
   --  method to create children.
   overriding
   procedure Build_Components (Node    : access Composition_Tag_Node;
                               Parent  : in UIComponent_Access;
                               Context : in out Facelet_Context'Class);

   --  Freeze the tag node tree and perform any initialization steps
   --  necessary to build the components efficiently.  After this call
   --  the tag node tree should not be modified and it represents a read-only
   --  tree.
   overriding
   procedure Freeze (Node : access Composition_Tag_Node);

   --  Include in the component tree the definition identified by the name.
   --  Upon completion, return in <b>Found</b> whether the definition was found
   --  within this composition context.
   procedure Include_Definition (Node    : access Composition_Tag_Node;
                                 Parent  : in UIComponent_Access;
                                 Context : in out Facelet_Context'Class;
                                 Name    : in Unbounded_String;
                                 Found   : out Boolean);

   --  ------------------------------
   --  Debug Tag
   --  ------------------------------
   --  The <ui:debug/>
   type Debug_Tag_Node is new Tag_Node with private;
   type Debug_Tag_Node_Access is access all Debug_Tag_Node'Class;

   --  Create the Debug Tag
   function Create_Debug_Tag_Node (Binding    : in Binding_Access;
                                   Line       : in Line_Info;
                                   Parent     : in Tag_Node_Access;
                                   Attributes : in Tag_Attribute_Array_Access)
                                   return Tag_Node_Access;

   --  Build the component tree from the tag node and attach it as
   --  the last child of the given parent.  Calls recursively the
   --  method to create children.
   overriding
   procedure Build_Components (Node    : access Debug_Tag_Node;
                               Parent  : in UIComponent_Access;
                               Context : in out Facelet_Context'Class);

   --  ------------------------------
   --  Decorate Tag
   --  ------------------------------
   --  The <ui:decorate template="...">...</ui:decorate>
   type Decorate_Tag_Node is new Composition_Tag_Node with private;
   type Decorate_Tag_Node_Access is access all Decorate_Tag_Node'Class;

   --  Create the Decorate Tag
   function Create_Decorate_Tag_Node (Binding    : in Binding_Access;
                                      Line       : in Line_Info;
                                      Parent     : in Tag_Node_Access;
                                      Attributes : in Tag_Attribute_Array_Access)
                                      return Tag_Node_Access;

   --  ------------------------------
   --  Define Tag
   --  ------------------------------
   --  The <ui:define name="...">...</ui:define>
   type Define_Tag_Node is new Tag_Node with private;
   type Define_Tag_Node_Access is access all Define_Tag_Node'Class;

   --  Create the Define Tag
   function Create_Define_Tag_Node (Binding    : in Binding_Access;
                                    Line       : in Line_Info;
                                    Parent     : in Tag_Node_Access;
                                    Attributes : in Tag_Attribute_Array_Access)
                                    return Tag_Node_Access;

   --  Build the component tree from the tag node and attach it as
   --  the last child of the given parent.  Calls recursively the
   --  method to create children.
   overriding
   procedure Build_Components (Node    : access Define_Tag_Node;
                               Parent  : in UIComponent_Access;
                               Context : in out Facelet_Context'Class);

   --  ------------------------------
   --  Insert Tag
   --  ------------------------------
   --  The <ui:insert name="...">...</ui:insert>
   type Insert_Tag_Node is new Tag_Node with private;
   type Insert_Tag_Node_Access is access all Insert_Tag_Node'Class;

   --  Create the Insert Tag
   function Create_Insert_Tag_Node (Binding    : in Binding_Access;
                                    Line       : in Line_Info;
                                    Parent     : in Tag_Node_Access;
                                    Attributes : in Tag_Attribute_Array_Access)
                                    return Tag_Node_Access;

   --  Build the component tree from the tag node and attach it as
   --  the last child of the given parent.  Calls recursively the
   --  method to create children.
   overriding
   procedure Build_Components (Node    : access Insert_Tag_Node;
                               Parent  : in UIComponent_Access;
                               Context : in out Facelet_Context'Class);

   --  ------------------------------
   --  Param Tag
   --  ------------------------------
   --  The <ui:param name="name" value="#{expr}"/> parameter creation.
   --  The parameter is created in the faces context.
   type Param_Tag_Node is new Tag_Node with private;
   type Param_Tag_Node_Access is access all Param_Tag_Node'Class;

   --  Create the Param Tag
   function Create_Param_Tag_Node (Binding    : in Binding_Access;
                                   Line       : in Line_Info;
                                   Parent     : in Tag_Node_Access;
                                   Attributes : in Tag_Attribute_Array_Access)
                                   return Tag_Node_Access;

   --  Build the component tree from the tag node and attach it as
   --  the last child of the given parent.  Calls recursively the
   --  method to create children.
   overriding
   procedure Build_Components (Node    : access Param_Tag_Node;
                               Parent  : in UIComponent_Access;
                               Context : in out Facelet_Context'Class);

   --  ------------------------------
   --  Comment Tag
   --  ------------------------------
   --  The <ui:comment condition="...">...</ui:comment>
   type Comment_Tag_Node is new Tag_Node with private;
   type Comment_Tag_Node_Access is access all Comment_Tag_Node'Class;

   --  Create the Comment Tag
   function Create_Comment_Tag_Node (Binding    : in Binding_Access;
                                     Line       : in Line_Info;
                                     Parent     : in Tag_Node_Access;
                                     Attributes : in Tag_Attribute_Array_Access)
                                     return Tag_Node_Access;

   --  Build the component tree from the tag node and attach it as
   --  the last child of the given parent.  Calls recursively the
   --  method to create children.
   overriding
   procedure Build_Components (Node    : access Comment_Tag_Node;
                               Parent  : in UIComponent_Access;
                               Context : in out Facelet_Context'Class);

private

   --  Tag library map indexed on the library namespace.
   package Define_Maps is new
     Ada.Containers.Indefinite_Hashed_Maps (Key_Type        => String,
                                            Element_Type    => Define_Tag_Node_Access,
                                            Hash            => Ada.Strings.Hash,
                                            Equivalent_Keys => "=");

   type Include_Tag_Node is new Tag_Node with record
      Source : Tag_Attribute_Access;
   end record;

   type Composition_Tag_Node is new Tag_Node with record
      Template : Tag_Attribute_Access;
      Defines  : Define_Maps.Map;
   end record;

   type Debug_Tag_Node is new Tag_Node with record
      Source : Tag_Attribute_Access;
   end record;

   type Decorate_Tag_Node is new Composition_Tag_Node with null record;

   type Define_Tag_Node is new Tag_Node with record
      Define_Name : Unbounded_String;
   end record;

   type Insert_Tag_Node is new Tag_Node with record
      Insert_Name : Tag_Attribute_Access;
   end record;

   type Param_Tag_Node is new Tag_Node with record
      Var   : Tag_Attribute_Access;
      Value : Tag_Attribute_Access;
   end record;

   type Comment_Tag_Node is new Tag_Node with record
      Condition : Tag_Attribute_Access;
   end record;

end ASF.Views.Nodes.Facelets;
