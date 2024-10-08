import Error "mo:base/Error";

import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Option "mo:base/Option";

actor {
  type Expression = {
    #Variable : Text;
    #Abstraction : { param : Text; body : Expression };
    #Application : { fn : Expression; arg : Expression };
  };

  func parseExpression(input : Text) : ?Expression {
    let tokens = Iter.toArray(Text.tokens(input, #text(" ")));
    var index = 0;

    func parseNext() : ?Expression {
      if (index >= tokens.size()) {
        return null;
      };

      let token = tokens[index];
      index += 1;

      switch (token) {
        case "(" {
          let expr = parseNext();
          if (index < tokens.size() and tokens[index] == ")") {
            index += 1;
            return expr;
          } else {
            return null; // Mismatched parentheses
          };
        };
        case "\\" {
          if (index + 2 < tokens.size() and tokens[index + 1] == ".") {
            let param = tokens[index];
            index += 2;
            switch (parseNext()) {
              case (?body) {
                return ?#Abstraction({ param = param; body = body });
              };
              case (null) {
                return null;
              };
            };
          } else {
            return null; // Invalid abstraction syntax
          };
        };
        case _ {
          if (index < tokens.size()) {
            switch (parseNext()) {
              case (?arg) {
                return ?#Application({ fn = #Variable(token); arg = arg });
              };
              case (null) {
                return ?#Variable(token);
              };
            };
          } else {
            return ?#Variable(token);
          };
        };
      };
    };

    parseNext();
  };

  func substitute(expr : Expression, param : Text, arg : Expression) : Expression {
    switch (expr) {
      case (#Variable(x)) {
        if (x == param) arg else expr;
      };
      case (#Abstraction({ param = p; body })) {
        if (p == param) {
          expr;
        } else {
          #Abstraction({ param = p; body = substitute(body, param, arg) });
        };
      };
      case (#Application({ fn; arg = a })) {
        #Application({
          fn = substitute(fn, param, arg);
          arg = substitute(a, param, arg);
        });
      };
    };
  };

  func reduce(expr : Expression) : Expression {
    switch (expr) {
      case (#Application({ fn = #Abstraction({ param; body }); arg })) {
        reduce(substitute(body, param, arg));
      };
      case (#Application({ fn; arg })) {
        let reducedFn = reduce(fn);
        if (reducedFn == fn) {
          #Application({ fn = reducedFn; arg = reduce(arg) });
        } else {
          reduce(#Application({ fn = reducedFn; arg }));
        };
      };
      case (#Abstraction({ param; body })) {
        #Abstraction({ param; body = reduce(body) });
      };
      case _ {
        expr;
      };
    };
  };

  func expressionToText(expr : Expression) : Text {
    switch (expr) {
      case (#Variable(x)) x;
      case (#Abstraction({ param; body })) {
        "\\" # param # "." # expressionToText(body);
      };
      case (#Application({ fn; arg })) {
        "(" # expressionToText(fn) # " " # expressionToText(arg) # ")";
      };
    };
  };

  public func evaluate(input : Text) : async Text {
    switch (parseExpression(input)) {
      case (?expr) {
        let reduced = reduce(expr);
        "Input: " # input # "\nParsed: " # expressionToText(expr) # "\nReduced: " # expressionToText(reduced);
      };
      case (null) {
        "Error: Invalid input";
      };
    };
  };
};
