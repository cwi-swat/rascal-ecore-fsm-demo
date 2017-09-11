package model.menu;

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
			//EditingDomain editingDomain = AdapterFactoryEditingDomain.getEditingDomainFor(m);
			
			// Do the actual trafo here
			//State s = CustomFactory.eINSTANCE.createFinalState();
			//Command c = AddCommand.create(editingDomain, m, CustomPackage.eINSTANCE.getMachine_State(), s);

			// Apply the patch
			//editingDomain.getCommandStack().execute(c);
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
