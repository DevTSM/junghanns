enum NewTypeUser{
  particular,
  empresa,
  deposito,
  colaborador
}
NewTypeUser getNewTypeUserCambaceo(String type){
  switch (type){
    case "PARTICULAR":
    return NewTypeUser.particular;
    case "DEPOSITO":
    return NewTypeUser.deposito;
    case "EMPRESA":
    return NewTypeUser.empresa;
    case "COLABORADOR":
    return NewTypeUser.colaborador;
    default:
    return NewTypeUser.particular;
  }
}
String getTypeUserCambaceo(NewTypeUser type){
  switch (type){
    case NewTypeUser.particular:
    return "PARTICULAR";
    case NewTypeUser.deposito:
    return "DEPOSITO";
    case NewTypeUser.empresa:
    return "EMPRESA";
    case NewTypeUser.colaborador:
    return "COLABORADOR";
    default:
    return "NO ESPECIFICADO";
  }
}
String getCharUserCambaceo(NewTypeUser type){
  switch (type){
    case NewTypeUser.particular:
    return "P";
    case NewTypeUser.deposito:
    return "D";
    case NewTypeUser.empresa:
    return "E";
     case NewTypeUser.colaborador:
    return "T";
    default:
    return "NO ESPECIFICADO";
  }
}