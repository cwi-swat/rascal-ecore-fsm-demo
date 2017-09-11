package model.menu;

import org.eclipse.emf.common.command.Command;
import org.eclipse.emf.edit.domain.AdapterFactoryEditingDomain;
import org.eclipse.emf.edit.domain.EditingDomain;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IWorkbenchPart;

import model.Machine;

public class AddStateTrafo implements org.eclipse.ui.IObjectActionDelegate {
	private Machine m;

	@Override
	public void run(IAction action) {
		if (m != null) {
			// Get the editing domain
			EditingDomain editingDomain = AdapterFactoryEditingDomain.getEditingDomainFor(m);
			Command cmd = lang.ecore.IO.runRascal("myfsm.editor", editingDomain, m, "lang::myfsm::Trafos", "runAddState"); 
			editingDomain.getCommandStack().execute(cmd);
		}
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		m = (Machine) ((IStructuredSelection) selection).getFirstElement();
	}

	@Override
	public void setActivePart(IAction arg0, IWorkbenchPart arg1) {
		// Ignore
	}
}
