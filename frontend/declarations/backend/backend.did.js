export const idlFactory = ({ IDL }) => {
  return IDL.Service({ 'evaluate' : IDL.Func([IDL.Text], [IDL.Text], []) });
};
export const init = ({ IDL }) => { return []; };
